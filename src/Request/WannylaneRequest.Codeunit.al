namespace Wanamics.Wannylane.Request;

using System.Security.Authentication;
using Wanamics.Wannylane.Setup;
codeunit 87431 "Wannylane Request"
{
    var
        WannylaneSetup: Record "Wannylane Setup";
        Helper: Codeunit "Wannylane Helper";

    procedure GET(pRequest: Text): JsonToken;
    var
        DummyContent: HttpContent;
    begin
        exit(Request("Http Request Type"::GET, pRequest, DummyContent));
    end;

    procedure POST(pRequest: Text; pContent: HttpContent): JsonToken
    begin
        exit(Request("Http Request Type"::POST, pRequest, pContent));
    end;

    procedure DELETE(pRequest: Text): JsonToken
    var
        Content: HttpContent;
    begin
        exit(Request("Http Request Type"::DELETE, pRequest, Content));
    end;

    local procedure Request(pRequestType: Enum "Http Request Type"; pRequest: Text; pContent: HttpContent): JsonToken
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Secret: SecretText;
    begin
        WannylaneSetup.Get();
        WannylaneSetup.TestField("Base Address");
        WannylaneSetup.GetSecret(Secret);
        WannylaneSetup.TestField("Enabled");

        Client.SetBaseAddress(WannylaneSetup."Base Address");
        Client.DefaultRequestHeaders.Clear();
        Client.DefaultRequestHeaders.Add('accept', 'application/json');
        Client.DefaultRequestHeaders.Add('authorization', SecretStrSubstNo('Bearer %1', Secret));

        pContent.GetHeaders(Headers);
        exit(Helper.Request(Client, pRequestType, pRequest, pContent));
    end;

}
