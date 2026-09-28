namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
pageextension 87432 "Wannylane Pmt. Rec Match Det." extends "Payment Rec Match Details"
{
    layout
    {
        addfirst(content)
        {
            field(WannylaneTransactionText; Rec."Transaction Text")
            {
                ApplicationArea = All;
                MultiLine = true;
                ShowCaption = false;
            }
            field(WannylaneVATAmount; abs(VATAmount))
            {
                ApplicationArea = All;
                Caption = 'VAT Amount Incl.';
                ToolTip = 'VAT Amount';
            }
        }
    }
    var
        VATAmount: Decimal;

    trigger OnAfterGetCurrRecord()
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATAmount := 0;
        if (Rec."Account Type" <> Rec."Account Type"::"G/L Account") or (Rec."Account No." = '') then
            exit;
        GLAccount.Get(Rec."Account No.");
        if not (GLAccount."Gen. Posting Type" in [GLAccount."Gen. Posting Type"::"Purchase", GLAccount."Gen. Posting Type"::Sale]) then
            exit;
        GLAccount.TestField("VAT Bus. Posting Group");
        GLAccount.TestField("VAT Prod. Posting Group");
        VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        VATAmount := Round(Rec."Statement Amount" * (1 - 1 / (1 + VATPostingSetup."VAT %" / 100)));
    end;
}
