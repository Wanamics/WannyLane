namespace Wanamics.Wannylane.Request;

using System.Security.Authentication;
using Wanamics.Wannylane.Setup;
codeunit 87431 "Wannylane Request"
{
    var
        WannylaneSetup: Record "Wannylane Setup";
        ApiKey: SecretText;

    procedure GET(pRequest: Text) ReturnValue: JsonToken
    var
        DummyContent: HttpContent;
    begin
        Request("Http Request Type"::GET, pRequest, DummyContent, ReturnValue);
    end;

    procedure POST(pRequest: Text; pContent: HttpContent; var pToken: JsonToken)
    begin
        Request("Http Request Type"::POST, pRequest, pContent, pToken);
    end;

    procedure DELETE(pRequest: Text; var pToken: JsonToken)
    var
        Content: HttpContent;
    begin
        Request("Http Request Type"::DELETE, pRequest, Content, pToken);
    end;

    local procedure Request(pRequestType: Enum "Http Request Type"; pRequest: Text; pContent: HttpContent; var pToken: JsonToken)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ConnectErr: Label 'An error occurred connecting to Wannylane';
        RequestTypeErr: Label '%1 Request Type not implemented', Comment = '%1: Http Request Type';
        ContentHeaders: HttpHeaders;
        ResponseText: Text;
    begin
        WannylaneSetup.Get();
        WannylaneSetup.TestField("Base Endpoint");
        WannylaneSetup.GetApiKey(ApiKey);
        WannylaneSetup.TestField("Enabled");

        Client.DefaultRequestHeaders.Clear();
        Client.DefaultRequestHeaders.Add('authorization', SecretStrSubstNo('Bearer %1', ApiKey));
        pContent.GetHeaders(ContentHeaders);

        case pRequestType of
            "Http Request Type"::GET:
                if not Client.Get(WannylaneSetup."Base Endpoint" + pRequest, ResponseMessage) then
                    Error(ConnectErr);
            "Http Request Type"::POST:
                if not Client.Post(WannylaneSetup."Base Endpoint" + pRequest, pContent, ResponseMessage) then
                    Error(ConnectErr);
            "Http Request Type"::DELETE:
                if not Client.Delete(WannylaneSetup."Base Endpoint" + pRequest, ResponseMessage) then
                    Error(ConnectErr);
            else
                Error(RequestTypeErr, pRequestType);
        end;
        if not ResponseMessage.IsSuccessStatusCode then
            HandleError(pRequest, ResponseMessage)
        else
            if ResponseMessage.Content.ReadAs(ResponseText) and (ResponseText <> '') then
                pToken.ReadFrom(ResponseText);
    end;

    local procedure HandleError(pRequest: Text; pResponseMessage: HttpResponseMessage)
    var
        ApiErr: Label 'Wannylane API return an error : %1 %2\%3', Comment = '%1:StatusCode, %2:ReasonPhrase, %3:Content';
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
                Error(ApiErr, pResponseMessage.HttpStatusCode, pResponseMessage.ReasonPhrase, ResponseText);
        end;
    end;
}
