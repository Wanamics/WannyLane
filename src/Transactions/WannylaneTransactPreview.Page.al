namespace Wanamics.Wannylane.Transactions;
using Microsoft.Bank.BankAccount;
using Wanamics.Wannylane.Connect;
page 87432 "Wannylane Transaction Preview"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Wannylane Transactions Preview';
    PageType = List;
    SourceTable = "Wannylane Transaction Proxy";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.id) { }
                field(clean_description; Rec.label) { }
                field(amount; Rec.amount) { }
                field("date"; Rec."date") { }
                field(updated_at; Rec.updated_at)
                {
                    Visible = false;
                }
                field(currency; Rec.currency)
                {
                    Visible = false;
                }
                field("bank_account.id"; Rec."bank_account.id")
                {
                    // Style = Attention;
                    // StyleExpr = not IsLinked;
                }
                field(BankAccountNo; BankAccount."No.")
                {
                    Caption = 'Bank Account No.';
                    ToolTip = 'Linked to Bank Account No.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Load();
    end;

    trigger OnAfterGetRecord()
    var
        WannylaneBankAccount: Record "Wannylane Bank Account Proxy";
    begin
        // if not Account.Get(Rec.account_id) then
        //     Account.init();
        // if not Category.Get(Rec.category_id) then
        //     Category.init();
        WannylaneBankAccount.id := Rec."bank_account.id";
        BankAccount := WannylaneBankAccount.GetBankAccount();
        // IsLinked := BankAccount."No." <> '';
    end;

    var
        BankAccount: Record "Bank Account";
    // IsLinked: Boolean;
    //     Account: Record "Wannylane Bank Account";
    //     Category: Record "Wannylane Category";
}
