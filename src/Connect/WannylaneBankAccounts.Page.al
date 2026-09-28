namespace Wanamics.Wannylane.Connect;

using Microsoft.Bank.BankAccount;
using Wanamics.Wannylane.Transactions;
page 87431 "Wannylane Bank Accounts"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Wannylane Bank Accounts';
    PageType = List;
    SourceTable = "Wannylane Bank Account Proxy";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                }
                field(Name; Rec.Name)
                {
                }
                field("Currency Code"; Rec.currency)
                {
                }
                // field(IBAN; Rec.iban)
                // {
                // }
                field(BankAccountNo; Rec.GetBankAccount()."No.")
                {
                    Caption = 'Bank Account No.';
                    Tooltip = 'Bank Account No.';
                    // trigger OnLookup(var Text: Text): Boolean
                    // var
                    //     BankAccount: Record "Bank Account";
                    //     AlreadyLinkedErr: Label 'is already Linked to %1', Comment = '%1: Pennylane bank account id';
                    // begin
                    //     BankAccount := GetBankAccount();
                    //     if Page.RunModal(0, BankAccount) = Action::LookupOK then begin
                    //         BankAccount.Get(BankAccount."No.");
                    //         if BankAccount."Wannylane Bank Account ID" <> 0 then
                    //             BankAccount.FieldError("Wannylane Bank Account ID", StrSubstNo(AlreadyLinkedErr, Rec.id));
                    //         BankAccount."Wannylane Bank Account ID" := Rec.id;
                    //         BankAccount.Modify(true);
                    //     end;
                    // end;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(WannylaneTransactionsPreview)
            {
                Caption = 'Transactions Preview';
                ToolTip = 'Transactions Preview';
                Image = Accounts;
                RunObject = page "Wannylane Transaction Preview";
                //?? RunPageLink = account_id = field(id);
            }
        }
        area(Processing)
        {
            action(LinkToBankAccount)
            {
                Caption = 'Link to Bank Account';
                ToolTip = 'Link to Bank Account';
                Image = MapAccounts;
                trigger OnAction()
                begin
                    LinkBankAccounts();
                end;

            }
            action(CreateBankAccounts)
            {
                Caption = 'Create Bank Accounts';
                ToolTip = 'Create Bank Accounts';
                Image = BankAccount;
                trigger OnAction()
                var
                    lRec: Record "Wannylane Bank Account Proxy";
                    BankAccount: Record "Bank Account";
                    ConfirmLbl: Label 'Do you want to create %1 "%2"?', Comment = '%1:Count, %2:BankAccount.TableCaption';
                begin
                    CurrPage.SetSelectionFilter(lRec);
                    if not Confirm(ConfirmLbl, false, lRec.Count, BankAccount.TableCaption) then
                        exit;
                    if lRec.FindSet() then
                        repeat
                            lRec.CreateBankAccount(BankAccount);
                            BankAccount.Mark(true);
                        until lRec.Next() = 0;
                    BankAccount.MarkedOnly(true);
                    Commit();
                    Page.RunModal(Page::"Bank Account List", BankAccount, BankAccount."Bank Acc. Posting Group");
                end;
            }
        }
        area(Promoted)
        {
            actionref(LinkToBankAccount_Promoted; LinkToBankAccount) { }
            actionref(CreateBankAccount_Promoted; CreateBankAccounts) { }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Load();
    end;


    local procedure LinkBankAccounts()
    var
        BankAccount: Record "Bank Account";
        AlreadyLinkedMsg: Label '%1 is already Linked to %2.', Comment = '%1: Pennylane bank account id, %2: Bank Account No.';
        ContinueMsg: Label 'Do you wan to continue?';
    begin
        BankAccount := Rec.GetBankAccount();
        if BankAccount."Wannylane Bank Account ID" <> 0 then
            if not Confirm(AlreadyLinkedMsg + '\' + ContinueMsg, false, Rec.Id, BankAccount."No.") then
                exit;
        if Page.RunModal(0, BankAccount) = Action::LookupOK then begin
            BankAccount.Get(BankAccount."No.");
            if BankAccount."Wannylane Bank Account ID" = Rec.id then
                exit;
            if BankAccount."Wannylane Bank Account ID" <> 0 then
                if not Confirm(AlreadyLinkedMsg + '\' + ContinueMsg, false, BankAccount."No.", Rec.Id) then
                    exit;
            // BankAccount.FieldError("Wannylane Bank Account ID", StrSubstNo(AlreadyLinkedMsg, Rec.id));
            BankAccount."Wannylane Bank Account ID" := Rec.id;
            BankAccount.Modify(true);
        end;
    end;
}
