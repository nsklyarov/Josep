program program_jwt;

{$mode delphi}

uses
  SysUtils,
  Josep;

var
  Secret: string;
  PayloadJSON: string;
  Token: string;
  ValidationResult: TJWTValidationResult;

begin
  Secret := 'mysecretkey';

  PayloadJSON := '{"sub":"1234567890","name":"John Doe","admin":true,"exp":2147483647}';

  Token := EncodeJWT(PayloadJSON, Secret);
  Writeln('🔐 JWT Token:');
  Writeln(Token);
  Writeln;

  ValidationResult := DecodeAndVerifyJWT(Token, Secret);

  if ValidationResult.IsValid then
  begin
    Writeln('✅ Token is valid');
    Writeln('📦 Payload:');
    Writeln(ValidationResult.PayloadJSON);
  end
  else
  begin
    Writeln('❌ Token is invalid: ', ValidationResult.ErrorMessage);
  end;

  Writeln;
  Write('🔚 Press Enter to exit...');
  Readln;
end.
