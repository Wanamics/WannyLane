namespace Wanamics.Wannylane.Request;

using System.Security.Authentication;
codeunit 87434 "Wannylane Helper"
{
    procedure Request(pClient: HttpClient; pRequestType: Enum "Http Request Type"; pRequest: Text; pContent: HttpContent) Return: JsonToken
    var
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ConnectErr: Label 'An error occurred connecting to %1', Comment = '%1:URI';
        RequestTypeErr: Label '%1 Request Type not implemented for %2', Comment = '%1: Http Request Type, %2:URI';
    begin
        case pRequestType of
            "Http Request Type"::GET:
                if not pClient.Get(pClient.GetBaseAddress + pRequest, ResponseMessage) then
                    Error(ConnectErr, pRequest);
            "Http Request Type"::POST:
                if not pClient.Post(pClient.GetBaseAddress + pRequest, pContent, ResponseMessage) then
                    Error(ConnectErr, pRequest);
            "Http Request Type"::DELETE:
                if not pClient.Delete(pClient.GetBaseAddress + pRequest, ResponseMessage) then
                    Error(ConnectErr, pRequest);
            else
                Error(RequestTypeErr, pRequestType, pRequest);
        end;
        if not ResponseMessage.IsSuccessStatusCode then
            HandleError(pRequest, ResponseMessage)
        else
            if ResponseMessage.Content.ReadAs(ResponseText) and (ResponseText <> '') then
                Return.ReadFrom(ResponseText);
    end;

    local procedure HandleError(pRequest: Text; pResponseMessage: HttpResponseMessage)
    var
        ApiErr: Label '%1 return an error : %2 %3\%4', Comment = '%1:URI, %2:StatusCode, %3:ReasonPhrase, %4:Content';
        ResponseText: Text;
        ErrorMessageErr: Label '%1 (%2)\%3 : %4', Comment = '%1:StatusShortName, %2 StatusCode, %3:Request, %4:Response';
        _400BadRequestErr: Label 'Bad request';
        _401AccessDeniedErr: Label 'Access denied';
        _402PaymentRequiredErr: Label 'Payment Required';
        _403ForbiddenErr: Label 'Forbidden';
        _404NotFoundErr: Label 'Not Found';
        _405MethodNotAllowedErr: Label 'Method not allowed';
        _408RequestTimeOutErr: Label 'Request timed out';
        _409ConflictErr: Label 'Conflict';
        _410GoneErr: Label 'Gone';
        _412PreconditionFailedErr: Label 'Precondition Failed';
        _413PayloadTooLargeRequestEntityTooLargeErr: label 'Payload Too Large / Request Entity Too Large';
        _429TooManyRequestsErr: Label 'TooManyRequests';
        _503ServiceTemporarilyUnavailableErr: Label 'Service Temporarily Unavailable';
        _504GatewayTimeoutErr: Label 'Gateway Timeout';
        Response: Text;

    begin
        pResponseMessage.Content.ReadAs(Response);
        case pResponseMessage.HttpStatusCode of
            400:
                Error(ErrorMessageErr, _400BadRequestErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            401:
                Error(ErrorMessageErr, _401AccessDeniedErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            402:
                Error(ErrorMessageErr, _402PaymentRequiredErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            403:
                Error(ErrorMessageErr, _403ForbiddenErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            404:
                Error(ErrorMessageErr, _404NotFoundErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            405:
                Error(ErrorMessageErr, _405MethodNotAllowedErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            408:
                Error(ErrorMessageErr, _408RequestTimeOutErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            409:
                Error(ErrorMessageErr, _409ConflictErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            410:
                Error(ErrorMessageErr, _410GoneErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            412:
                Error(ErrorMessageErr, _412PreconditionFailedErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            413:
                Error(ErrorMessageErr, _413PayloadTooLargeRequestEntityTooLargeErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            429:
                Error(ErrorMessageErr, _429TooManyRequestsErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            503:
                Error(ErrorMessageErr, _503ServiceTemporarilyUnavailableErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            504:
                Error(ErrorMessageErr, _504GatewayTimeoutErr, pResponseMessage.HttpStatusCode, pRequest, Response);
            else
                pResponseMessage.Content.ReadAs(ResponseText);
                Error(ApiErr, pRequest, pResponseMessage.HttpStatusCode, pResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;

    procedure TokenToRecRef(pToken: JsonToken; pRecRef: RecordRef)
    var
        FldRef: FieldRef;
        i: Integer;
        Text: Text;
        Token: JsonToken;
        Guid: Guid;
    begin
        for i := 1 to pRecRef.FieldCount do begin
            FldRef := pRecRef.FieldIndex(i);
            if FldRef.Name[1] in ['a' .. 'z'] then
                if pToken.SelectToken('$.' + FldRef.Name, Token) and not Token.AsValue().IsNull then
                    case FldRef.Type of
                        FldRef.Type::BigInteger:
                            FldRef.Validate(Token.AsValue().AsBigInteger());
                        FldRef.Type::Boolean:
                            FldRef.Validate(Token.AsValue().AsBoolean());
                        FldRef.Type::Date:
                            FldRef.Validate(Token.AsValue().AsDate());
                        FldRef.Type::DateTime:
                            FldRef.Validate(Token.AsValue().AsDateTime());
                        FldRef.Type::Decimal:
                            FldRef.Validate(Token.AsValue().AsDecimal());
                        FldRef.Type::Guid:
                            begin
                                Text := Token.AsValue().AsText();
                                Evaluate(Guid, Text);
                                FldRef.Validate(Guid);
                            end;
                        FldRef.Type::Integer:
                            FldRef.Validate(Token.AsValue().AsInteger());
                        FldRef.Type::Option:
                            FldRef.Validate(OrdinalValue(Token.AsValue().AsText(), FldRef.OptionMembers));
                        FldRef.Type::Code,
                        FldRef.Type::Text:
                            begin
                                Text := Token.AsValue().AsText();
                                if StrLen(Text) > FldRef.Length then
                                    Text := Text.Substring(1, FldRef.Length);
                                FldRef.Validate(Text)
                            end;
                        FldRef.Type::Time:
                            FldRef.Validate(Token.AsValue().AsTime());
                    end;
        end;
    end;

    local procedure OrdinalValue(pText: Text; pOptionMembers: Text): Integer
    var
        Members: List of [Text];
    begin
        Members := pOptionMembers.Split(',');
        exit(Members.IndexOf(pText) - 1);
    end;

    procedure Load(var pRecordRef: RecordRef; pRequest: Text; pPagination: Integer)
    begin
        if pRequest.Contains('?') then
            pRequest += '&'
        else
            pRequest += '?';
        Load(pRecordRef, pRequest + StrSubstNo('limit=%1', pPagination));
    end;

    procedure Load(var pRecordRef: RecordRef; pRequest: Text)
    var
        WannylaneRequest: Codeunit "Wannylane Request";
        ResponseToken: JsonToken;
        jToken: JsonToken;
        jItem: JsonToken;
        jArray: JsonArray;
        jObject: JsonObject;
        Cursor: Text;
        MustBeTemporaryErr: Label '%1 must be temporary.', Comment = '%1:TableCaption';
    begin
        if not pRecordRef.IsTemporary then
            Error(MustBeTemporaryErr, pRecordRef.Caption);
        pRecordRef.Reset();
        pRecordRef.DeleteAll(true);
        repeat
            ResponseToken := WannylaneRequest.GET(pRequest + Cursor);
            ResponseToken.SelectToken('items', jToken);
            jArray := jToken.AsArray();

            foreach jItem in jArray do begin
                pRecordRef.Init();
                TokenToRecRef(jItem, pRecordRef);
                if pRecordRef.Insert(true) then;
            end;

            ResponseToken.SelectToken('next_cursor', jToken);
            if jToken.AsValue().IsNull then
                exit;
            if pRequest.Contains('?') then
                Cursor := '&'
            else
                Cursor := '?';
            Cursor += 'cursor=' + jToken.AsValue().AsText();
        until false; //pRequest = '';
    end;
}
