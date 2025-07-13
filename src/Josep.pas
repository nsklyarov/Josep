unit Josep;

{$mode delphi}

interface

uses
  SysUtils, Classes, DateUtils, fpjson, jsonparser, Unix,
  ClpCryptoLibTypes,
  ClpIDigest,
  ClpDigestUtilities,
  ClpHMac,
  ClpKeyParameter,
  ClpICipherParameters,
  ClpIKeyParameter,
  ClpEncoders;

type
  TJWTValidationResult = record
    IsValid: Boolean;
    ErrorMessage: string;
    PayloadJSON: string;
  end;

function EncodeJWT(const PayloadJSON: string; const Secret: string): string;
function VerifyJWT(const Token, Secret: string): Boolean;
function DecodeAndVerifyJWT(const Token, Secret: string): TJWTValidationResult;

implementation

function CompareByteArrays(const A, B: TBytes): Boolean;
var
  i: Integer;
begin
  if Length(A) <> Length(B) then
    Exit(False);

  for i := 0 to High(A) do
    if A[i] <> B[i] then
      Exit(False);

  Result := True;
end;

function EncodeBase64(const Input: TBytes): string;
begin
  Result := TBase64.Encode(Input);
end;

function DecodeBase64(const S: string): TBytes;
begin
  Result := TBase64.Decode(S);
end;

function Base64URLEncode(const Input: TBytes): string;
begin
  Result := EncodeBase64(Input);
  Result := StringReplace(Result, '+', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '=', '', [rfReplaceAll]);
end;

function Base64URLDecode(const Input: string): TBytes;
var
  S, Padding: string;
begin
  S := StringReplace(Input, '-', '+', [rfReplaceAll]);
  S := StringReplace(S, '_', '/', [rfReplaceAll]);

  case Length(S) mod 4 of
    2: Padding := '==';
    3: Padding := '=';
  else
    Padding := '';
  end;

  S := S + Padding;
  Result := DecodeBase64(S);
end;

function HMAC_SHA256(const Key, Data: TBytes): TBytes;
var
  Digest: IDigest;
  HMAC: THMAC;
  KeyParam: ICipherParameters;
begin
  Digest := TDigestUtilities.GetDigest('SHA-256');

  HMAC := THMAC.Create(Digest);
  try
    KeyParam := TKeyParameter.Create(Key);
    HMAC.Init(KeyParam);
    HMAC.BlockUpdate(Data, 0, Length(Data));

    SetLength(Result, Digest.GetDigestSize);
    HMAC.DoFinal(Result, 0);
  finally
    HMAC.Free;
  end;
end;

function EncodeJWT(const PayloadJSON: string; const Secret: string): string;
var
  HeaderJSON: string;
  HeaderEnc, PayloadEnc, SignatureEnc: string;
  Data: string;
  Signature: TBytes;
begin
  HeaderJSON := '{"alg":"HS256","typ":"JWT"}';

  HeaderEnc := Base64URLEncode(TEncoding.UTF8.GetBytes(HeaderJSON));
  PayloadEnc := Base64URLEncode(TEncoding.UTF8.GetBytes(PayloadJSON));
  Data := HeaderEnc + '.' + PayloadEnc;

  Signature := HMAC_SHA256(BytesOf(Secret), BytesOf(Data));
  SignatureEnc := Base64URLEncode(Signature);

  Result := Data + '.' + SignatureEnc;
end;

function VerifyJWT(const Token, Secret: string): Boolean;
var
  R: TJWTValidationResult;
begin
  R := DecodeAndVerifyJWT(Token, Secret);
  Result := R.IsValid;
end;

function DecodeAndVerifyJWT(const Token, Secret: string): TJWTValidationResult;
var
  Parts: TArray<string>;
  HeaderEnc, PayloadEnc, SignatureEnc, Data: string;
  HeaderJSON, PayloadJSON: string;
  ExpectedSignature, ActualSignature: TBytes;
  JSONData: TJSONData;
  ExpUnix, NbfUnix, IatUnix, NowUnix: Int64;
  JsonNode: TJSONData;
begin
  Result.IsValid := False;

  if Trim(Token) = '' then
  begin
    Result.ErrorMessage := 'Token is empty';
    Exit;
  end;

  if Trim(Secret) = '' then
  begin
    Result.ErrorMessage := 'Secret is empty';
    Exit;
  end;

  Parts := Token.Split(['.']);
  if Length(Parts) <> 3 then
  begin
    Result.ErrorMessage := 'Token must consist of 3 parts';
    Exit;
  end;

  HeaderEnc := Parts[0];
  PayloadEnc := Parts[1];
  SignatureEnc := Parts[2];

  HeaderJSON := TEncoding.UTF8.GetString(Base64URLDecode(HeaderEnc));
  if not HeaderJSON.Contains('"alg":"HS256"') then
  begin
    Result.ErrorMessage := 'Unsupported algorithm';
    Exit;
  end;

  Data := HeaderEnc + '.' + PayloadEnc;
  ExpectedSignature := HMAC_SHA256(BytesOf(Secret), BytesOf(Data));
  ActualSignature := Base64URLDecode(SignatureEnc);

  if not CompareByteArrays(ExpectedSignature, ActualSignature) then
  begin
    Result.ErrorMessage := 'Signature does not match';
    Exit;
  end;

  // Decode and validate payload
  PayloadJSON := TEncoding.UTF8.GetString(Base64URLDecode(PayloadEnc));
  Result.PayloadJSON := PayloadJSON;

  try
    JSONData := GetJSON(PayloadJSON);
    try
      NowUnix := DateTimeToUnix(Now);

      JsonNode := JSONData.FindPath('exp');
      if JsonNode <> nil then
        ExpUnix := StrToInt64Def(JsonNode.AsString, -1)
      else
        ExpUnix := -1;

      if (ExpUnix > 0) and (NowUnix >= ExpUnix) then
      begin
        Result.ErrorMessage := 'Token has expired';
        Exit;
      end;

      JsonNode := JSONData.FindPath('nbf');
      if JsonNode <> nil then
        NbfUnix := StrToInt64Def(JsonNode.AsString, -1)
      else
        NbfUnix := -1;

      if (NbfUnix > 0) and (NowUnix < NbfUnix) then
      begin
        Result.ErrorMessage := 'Token is not valid yet (nbf)';
        Exit;
      end;

      JsonNode := JSONData.FindPath('iat');
      if JsonNode <> nil then
        IatUnix := StrToInt64Def(JsonNode.AsString, -1)
      else
        IatUnix := -1;

      if (IatUnix > 0) and (NowUnix + 60 < IatUnix) then
      begin
        Result.ErrorMessage := 'Token issued in the future (iat)';
        Exit;
      end;

    finally
      JSONData.Free;
    end;
  except
    on E: Exception do
    begin
      Result.ErrorMessage := 'Invalid JSON in payload: ' + E.Message;
      Exit;
    end;
  end;

  Result.IsValid := True;
end;

end.
