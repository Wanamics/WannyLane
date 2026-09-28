namespace Wanamics.Wannylane.Setup;

page 87436 "Wannylane Categories"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Wannylane Categories';
    PageType = List;
    SourceTable = "Wannylane Category Proxy";
    Editable = false;

    layout
    {
        area(Content)
        {

            repeater(General)
            {
                ShowAsTree = true;
                TreeInitialState = CollapseAll;
                //TODO IndentationColumn = Rec.Level;

                field(id; Rec.id)
                {

                }
                field(label; Rec.label)
                {
                }
                // field(parent_id; Rec.parent_id)
                // {
                // }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ToolTip = 'Refresh';
                Image = Refresh;
                trigger OnAction()
                var
                    ConfirmMsg: Label 'Do you wish to refresh this list?';
                begin
                    if not Rec.IsEmpty then
                        if not Confirm(ConfirmMsg) then
                            exit;
                    Rec.DeleteAll(true);
                    Rec.Load();
                end;
            }
        }
        area(Promoted)
        {
            actionref(GetAccounts_Promoted; Refresh) { }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Load();
    end;
}
