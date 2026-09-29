namespace Wanamics.Wannylane.Setup;

using System.Security.User;
using Wannylane.Wannylane;
using Wanamics.Wannylane.Connect;
using Wanamics.Wannylane.SupplierInvoices;
using Wanamics.Wannylane.Transactions;
page 87430 "Wannylane Setup"
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
                field("Base Address"; Rec."Base Address")
                {
                }
                field("Secret"; Secret)
                {
                    Caption = 'Secret';
                    ToolTip = 'Specifies the authentication secret.';
                    ApplicationArea = All;
                    MaskType = Concealed;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if Secret = '' then
                            Rec.DeleteSecret(false)
                        else begin
                            Rec.StoreSecret(Secret);
                            Secret := '****';
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
            action(PennylaneIncomingDocuments)
            {
                Caption = 'Pennylane Supplier Invoices';
                ToolTip = 'Pennylane Supplier Invoices';
                Image = "Invoicing-Document";
                RunObject = page "Wannylane Supplier Invoices";
            }
        }

        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                ToolTip = 'Test Connection';
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
            action(ProxyGenerator)
            {
                Caption = 'Proxy Generator';
                ToolTip = 'Proxy Generator';
                Image = Create;
                RunObject = Page "Wannylane Proxy Generator";
            }
        }
        area(Promoted)
        {
            actionRef(TestConnection_Promoted; TestConnection) { }
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
        Rec.SetKeysIfAvailable(Secret);
    end;

    var
        [NonDebuggable]
        Secret: Text;
}
