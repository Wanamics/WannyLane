namespace Wanamics.Wannylane.Transactions;

using System.Threading;

codeunit 87432 "Wannylane JobQueue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Wannylane Trans. to Reconcile");
    end;

    procedure Schedule()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"Wannylane Trans. to Reconcile");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run");
        JobQueueEntry.SetRange("Object ID to Run", JobQueueEntry."Object ID to Run");
        if not JobQueueEntry.FindFirst() then begin
            JobQueueEntry.Insert(true);
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            JobQueueEntry.Validate("Run on Mondays", true);
            JobQueueEntry.Validate("Run on Tuesdays", true);
            JobQueueEntry.Validate("Run on Wednesdays", true);
            JobQueueEntry.Validate("Run on Thursdays", true);
            JobQueueEntry.Validate("Run on Fridays", true);
            JobQueueEntry.Validate("Starting Time", 010000T);
            JobQueueEntry.Validate("Ending Time", 020000T);
            JobQueueEntry.Modify(true);
            Commit();
        end;
        JobQueueEntry.SetRecFilter();
        Page.RunModal(Page::"Job Queue Entry Card", JobQueueEntry)
    end;
}
