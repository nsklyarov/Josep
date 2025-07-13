program JosepTests;

{$mode delphi}

uses
  SysUtils, Josep, DateUtils;

procedure Assert(condition: Boolean; const Msg: string);
begin
  if not condition then
  begin
    Writeln('❌ FAILED: ', Msg);
    Halt(1);
  end;
end;

procedure Test_ValidJWT;
var
  Secret, Payload, Token: string;
  Result: TJWTValidationResult;
begin
  Secret := 'secret';
  Payload := Format('{"sub":"1","exp":%d}', [DateTimeToUnix(Now) + 3600]); // +1 hour
  Token := EncodeJWT(Payload, Secret);
  Result := DecodeAndVerifyJWT(Token, Secret);
  Assert(Result.IsValid, 'Token should be valid');
end;

procedure Test_InvalidSignature;
var
  Token: string;
  Result: TJWTValidationResult;
begin
  Token := EncodeJWT('{"sub":"x"}', 'rightsecret');
  Result := DecodeAndVerifyJWT(Token, 'wrongsecret');
  Assert(not Result.IsValid, 'Should detect invalid signature');
end;

procedure Test_ExpiredToken;
var
  Secret, Payload, Token: string;
  Result: TJWTValidationResult;
begin
  Secret := 'secret';
  Payload := Format('{"sub":"1","exp":%d}', [DateTimeToUnix(Now) - 10]); // expired 10s ago
  Token := EncodeJWT(Payload, Secret);
  Result := DecodeAndVerifyJWT(Token, Secret);
  Assert(not Result.IsValid and (Pos('expired', LowerCase(Result.ErrorMessage)) > 0), 'Should detect expired token');
end;

procedure Test_NotBefore;
var
  Secret, Payload, Token: string;
  Result: TJWTValidationResult;
begin
  Secret := 'secret';
  Payload := Format('{"sub":"1","nbf":%d}', [DateTimeToUnix(Now) + 60]); // not valid until 1 min later
  Token := EncodeJWT(Payload, Secret);
  Result := DecodeAndVerifyJWT(Token, Secret);
  Assert(not Result.IsValid and (Pos('nbf', LowerCase(Result.ErrorMessage)) > 0), 'Should detect nbf in future');
end;

procedure Test_MalformedToken;
var
  Result: TJWTValidationResult;
begin
  Result := DecodeAndVerifyJWT('abc.def', 'key');
  Assert(not Result.IsValid and (Pos('token must consist', LowerCase(Result.ErrorMessage)) > 0), 'Should detect bad format');
end;

begin
  Writeln('🔎 Running JWT tests...');

  Test_ValidJWT;
  Test_InvalidSignature;
  Test_ExpiredToken;
  Test_NotBefore;
  Test_MalformedToken;

  Writeln('✅ All tests passed');
end.
