namespace Wanamics.Wannylane.Setup;

page 87435 "Wannylane Bank Establishments"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Pennylane Bank Establishments';
    PageType = List;
    SourceTable = "Wannylane Bank Establ. Proxy";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.id)
                {
                }
                field(name; Rec.name)
                {
                }
                //     field(parent_name; Rec.parent_name)
                //     {
                //     }
                //     field(country_code; Rec.country_code)
                //     {
                //         Editable = false;
                //     }
                //     field(logo_url; Rec.logo_url)
                //     {
                //         Editable = false;
                //     }
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
                Tooltip = 'Refresh the list';
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
