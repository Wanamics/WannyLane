namespace Wanamics.Wannylane.Setup;

using Microsoft.Utilities;
codeunit 87430 "Wannylane Setup Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", OnRegisterServiceConnection, '', false, true)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        WannylaneSetup: Record "Wannylane Setup";
        RecRef: RecordRef;
    begin
        if not WannylaneSetup.Get() then begin
            WannylaneSetup.Init();
            WannylaneSetup.Insert();
        end;
        RecRef.GetTable(WannylaneSetup);

        if WannylaneSetup.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled;
        ServiceConnection.InsertServiceConnection(
          ServiceConnection, RecRef.RecordId, WannylaneSetup.TableCaption(), '', PAGE::"Wannylane Setup");
    end;

    // [EventSubscriber(ObjectType::Table, Database::User, OnBeforeValidateEvent, 'State', false, false)]
    // local procedure OnBeforeValidateState(var Rec: Record User; var xRec: Record User; CurrFieldNo: Integer)
    // var
    //     UserProxy: Record "Wannylane User Proxy";
    // begin
    //     if Rec.State = Rec.State::Enabled then
    //         exit;
    //     UserProxy.Remove(Rec);
    // end;

    // [EventSubscriber(ObjectType::Table, Database::User, OnBeforeDeleteEvent, '', false, false)]
    // local procedure OnBeforeDeleteUser(var Rec: Record User; RunTrigger: Boolean)
    // var
    //     UserProxy: Record "Wannylane User Proxy";
    // begin
    //     UserProxy.Remove(Rec);
    // end;
}
