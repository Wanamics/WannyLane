namespace Wanamics.Wannylane.Setup;
using Microsoft.Foundation.Company;
using Wanamics.Wannylane.Request;

codeunit 87436 "Wannylane Setup Check"
{
    TableNo = "Wannylane Setup";

    trigger OnRun()
    var
        CompanyInformation: Record "Company Information";
        Request: Codeunit "Wannylane Request";
        jResponse: JsonToken;
        jUserFirstName: JsonToken;
        jCompanyName: JsonToken;
        jScopes: JsonToken;
        jCompanyRegNo: JsonToken;
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("Registration No.");
        jResponse := Request.GET('/me');
        jResponse.SelectToken('$.user.first_name', jUserFirstName);
        jResponse.SelectToken('$.company.name', jCompanyName);
        jResponse.SelectToken('$.scopes', jScopes);
        Message('Hello %1, you are connected to %2 with scopes %3',
            jUserFirstName.AsValue().AsText(),
            jCompanyName.AsValue().AsText(),
            jScopes.AsArray());
        jResponse.SelectToken('$.company.reg_no', jCompanyRegNo);
        if jCompanyRegNo.AsValue().AsText() <> CompanyInformation."Registration No." then
            Message('WARNING : Pennylane reg_no ''%1'' is not equal to %2 "%3" ''%4''',
                jCompanyRegNo.AsValue().AsText(),
                CompanyInformation.TableCaption,
                CompanyInformation.FieldCaption("Registration No."),
                CompanyInformation."Registration No.");
    end;

}
