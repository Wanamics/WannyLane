namespace Wanamics.Wannylane.Setup;

using System.Security.User;
using Wanamics.Wannylane.Connect;
using Wanamics.Wannylane.Transactions;
#if AppSource
page 71544430 
#else
page 87430
#endif
"Wannylane Setup"
{

    PageType = Card;
    SourceTable = "Wannylane Setup";
    Caption = 'Wannylane Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Base Endpoint"; Rec."Base Endpoint")
                {
                }
                field("API Key"; ApiKey)
                {
                    Caption = 'API Token';
                    ToolTip = 'Specifies the token.';
                    ApplicationArea = All;
                    MaskType = Concealed;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if ApiKey = '' then
                            Rec.DeleteApiKey(false)
                        else begin
                            Rec.StoreApiKey(ApiKey);
                            ApiKey := '****';
                        end;
                    end;
                }
                field(Enabled; Rec.Enabled)
                {
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PennylaneBankAccounts)
            {
                Caption = 'Pennylane Bank Accounts';
                ToolTip = 'Pennylane Bank Accounts';
                Image = Bank;
                RunObject = page "Wannylane Bank Accounts";
            }
            action(PennylaneEstablishments)
            {
                Caption = 'Pennylane Establishments';
                ToolTip = 'Pennylane Establishments';
                Image = Bank;
                RunObject = page "Wannylane Bank Establishments";
            }
            action(PennylaneCategories)
            {
                Caption = 'Pennylane Categories';
                ToolTip = 'Pennylane Categories';
                Image = Bank;
                RunObject = page "Wannylane Categories";
            }
            action(PennylaneTrnasactionsPreview)
            {
                Caption = 'Pennylane Transactions Preview';
                ToolTip = 'Pennylane Transactions Preview';
                Image = BankAccountStatement;
                RunObject = page "Wannylane Transaction Preview";
            }
        }

        area(Processing)
        {
            action(TestAuthentication)
            {
                Caption = 'Test Authentication';
                ToolTip = 'Test Authentication';
                Image = Certificate;
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Wannylane Setup Check", Rec)
                end;
            }
            action(Schedule)
            {
                Caption = 'Schedule';
                ToolTip = 'Schedule';
                Image = Planning;
                trigger OnAction()
                var
                    WannylaneJobQueue: Codeunit "Wannylane JobQueue";
                begin
                    WannylaneJobQueue.Schedule();
                end;
            }
            action(ResetDefault)
            {
                Caption = 'Reset Default';
                ToolTip = 'Reset Default';
                Visible = false;
                Enabled = Rec.Enabled;
                Image = ResetStatus;
                trigger OnAction()
                var
                    ConfirmLbl: label 'WARNING :\Do you want to cancel all bank connections for all your companies?';
                begin
                    if not Confirm(ConfirmLbl, false) then
                        exit;
                    Rec.ResetDefault();
                end;
            }
        }
        area(Promoted)
        {
            actionRef(TestAuthentication_Promoted; TestAuthentication) { }
            actionref(PennylaneBankAccounts_Promoted; PennylaneBankAccounts) { }
        }
    }

    trigger OnOpenPage()
    var
        UserPermissions: Codeunit "User Permissions";
        MustBeSuperUserLbl: Label 'You must be a SUPER user.';
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            Error(MustBeSuperUserLbl);
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetKeysIfAvailable(ApiKey);
    end;

    var
        [NonDebuggable]
        ApiKey: Text;
}
