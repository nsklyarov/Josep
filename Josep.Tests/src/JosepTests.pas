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

procedure Test_ClaimsMatch;
var
  Secret, Payload, Token: string;
  Result: TJWTValidationResult;
begin
  Secret := 'secret';
  Payload := Format(
    '{"iss":"issuer1","sub":"user1","aud":"aud1","jti":"tokenid","typ":"JWT","exp":%d}',
    [DateTimeToUnix(Now) + 3600]);
  Token := EncodeJWT(Payload, Secret);

  Result := DecodeAndVerifyJWT(Token, Secret, 'issuer1', 'user1', 'aud1', 'tokenid', 'JWT');
  Assert(Result.IsValid, 'Claims should match and token be valid');

  Result := DecodeAndVerifyJWT(Token, Secret, 'wrongissuer', 'user1', 'aud1', 'tokenid', 'JWT');
  Assert(not Result.IsValid and (Pos('iss', LowerCase(Result.ErrorMessage)) > 0), 'Should detect iss mismatch');

  Result := DecodeAndVerifyJWT(Token, Secret, 'issuer1', 'wrongsub', 'aud1', 'tokenid', 'JWT');
  Assert(not Result.IsValid and (Pos('sub', LowerCase(Result.ErrorMessage)) > 0), 'Should detect sub mismatch');

  Result := DecodeAndVerifyJWT(Token, Secret, 'issuer1', 'user1', 'wrongaud', 'tokenid', 'JWT');
  Assert(not Result.IsValid and (Pos('aud', LowerCase(Result.ErrorMessage)) > 0), 'Should detect aud mismatch');

  Result := DecodeAndVerifyJWT(Token, Secret, 'issuer1', 'user1', 'aud1', 'wrongjti', 'JWT');
  Assert(not Result.IsValid and (Pos('jti', LowerCase(Result.ErrorMessage)) > 0), 'Should detect jti mismatch');

  Result := DecodeAndVerifyJWT(Token, Secret, 'issuer1', 'user1', 'aud1', 'tokenid', 'wrongtyp');
  Assert(not Result.IsValid and (Pos('typ', LowerCase(Result.ErrorMessage)) > 0), 'Should detect typ mismatch');
end;

begin
  Writeln('🔎 Running JWT tests...');

  Test_ValidJWT;
  Test_InvalidSignature;
  Test_ExpiredToken;
  Test_NotBefore;
  Test_MalformedToken;
  Test_ClaimsMatch;

  Writeln('✅ All tests passed');
end.
