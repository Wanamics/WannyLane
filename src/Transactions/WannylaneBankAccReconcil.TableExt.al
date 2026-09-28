namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;

tableextension 87431 "Wannylane Bank Acc. Reconcil." extends "Bank Acc. Reconciliation"
{
    fields
    {
#if AppSource
        field(71544430;
#else
        field(87430;
#endif
        "Wannylane Timestamp"; DateTime)
        {
            Caption = 'Wannylane Timestamp';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
    procedure Wannylane(): Boolean
    begin
        exit("Wannylane Timestamp" <> 0DT);
    end;
}
