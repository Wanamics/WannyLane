namespace Wannylane.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;

#if AppSource
page 71544433
#else
page 87433
#endif
"Wannylane Pmt. Rec. Split"
{
    ApplicationArea = All;
    Caption = 'Split Line';
    PageType = StandardDialog;
    SourceTable = "Bank Acc. Reconciliation Line";

    layout
    {
        area(Content)
        {
            field("Transaction Date"; Rec."Transaction Date")
            {
                ToolTip = 'Specifies the posting date of the bank account or check ledger entry on the reconciliation line when the Suggest Lines function is used.';
                Editable = false;
            }
            field("Transaction Text"; Rec."Transaction Text")
            {
                ToolTip = 'Specifies the text that the customer or vendor entered on that payment transaction that is represented by the journal line.';
                Editable = false;
            }
            field("Statement Amount"; Rec."Statement Amount")
            {
                ToolTip = 'Specifies the amount of the transaction on the bank''s statement shown on this reconciliation line.';
                Editable = false;
            }
            field("Split Amount"; SplitAmount)
            {
                Caption = 'Split Amount';
                ToolTip = 'Specifies the amount to be split.';
                BlankZero = true;
                trigger OnValidate()
                begin
                    if SplitAmount * Rec."Statement Amount" < 0 then
                        SplitAmount *= -1;
                end;
            }
        }
    }
    var
        SplitAmount: Decimal;

    procedure Split()
    var
        NextLine: Record "Bank Acc. Reconciliation Line";
        SplitLine: Record "Bank Acc. Reconciliation Line";
        SplitAmountMustBeSpecifiedErr: label 'The split amount must be specified.';
    begin
        if SplitAmount = 0 then
            Error(SplitAmountMustBeSpecifiedErr);
        SplitLine.Copy(Rec);
        NextLine.SetView(Rec.GetView());
        NextLine.SetFilter("Statement Line No.", '>%1', Rec."Statement Line No.");
        if NextLine.FindFirst() then
            SplitLine."Statement Line No." := (Rec."Statement Line No." + NextLine."Statement Line No.") div 2
        else
            SplitLine."Statement Line No." += 10000;
        SplitLine.Validate("Statement Amount", SplitAmount);
        SplitLine.Insert(true);
        Rec.Validate("Statement Amount", Rec."Statement Amount" - SplitAmount);
        Rec.Modify(true);
    end;

    procedure Merge()
    var
        NextLine: Record "Bank Acc. Reconciliation Line";
        NextLineErr: Label 'There is no next line to merge with.';
        MustHaveSameDateAndTextErr: Label 'The lines must have the same date and text.';
    begin
        Rec.TestField("Applied Amount", 0);
        NextLine.SetView(Rec.GetView());
        NextLine.SetFilter("Statement Line No.", '>%1', Rec."Statement Line No.");
        if not NextLine.FindFirst() then
            Error(NextLineErr);
        NextLine.TestField("Applied Amount", 0);
        if (Rec."Transaction Date" <> NextLine."Transaction Date") or
            (Rec."Transaction Text" <> NextLine."Transaction Text") then
            Error(MustHaveSameDateAndTextErr);
        NextLine.Delete(true);
        Rec.Validate("Statement Amount", Rec."Statement Amount" + NextLine."Statement Amount");
        Rec.Modify(true);
    end;
}
