page 7000002 "ePDF Queue List"
{
    PageType = List;
    SourceTable = "ePDF Queue";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {

                }
                field("Document Code"; "Document Code")
                {

                }
                field("Document No."; "Document No.")
                {

                }
                field("Entity Type"; "Entity Type")
                {

                }
                field("Entity No."; "Entity No.")
                {

                }
                field(Description; Description)
                {

                }
                field("Date Logged"; "Date Logged")
                {

                }
                field("Time Logged"; "Time Logged")
                {

                }
                field("Logged By"; "Logged By")
                {

                }
                field("PDF Path"; "PDF Path")
                {

                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                action("Process Queue - Create PDF and Send Email")
                {
                    Image = SendAsPDF;
                    Promoted = true;
                    trigger OnAction();
                    var
                        ePDFQueue : Record "ePDF Queue";
                        counter : integer;
                        FiltersText : Text;
                        window : Dialog;
                        ePDFMgmt : Codeunit "ePDF Management";
                    begin
                        Counter := 0;
                        ePDFQueue.COPY(Rec);
                        FiltersText := ePDFQueue.GETFILTERS;
                        IF ePDFQueue.FINDSET AND CONFIRM('Do you wish to process queue with following filters: \%1',TRUE,FiltersText) THEN 
                        BEGIN
                            IF GUIALLOWED THEN
                                Window.OPEN('Creating and Emailing ePDF Queue     #1####      of total     #2####');

                            IF GUIALLOWED THEN BEGIN
                                Window.UPDATE(1,Counter);
                                Window.UPDATE(2,ePDFQueue.COUNT);
                            END;

                            REPEAT
                                //error('Hello Debugger');
                                Counter += 1;
                                IF GUIALLOWED THEN
                                Window.UPDATE(1,Counter);
                                ePDFMgmt.CreatePDFandEmail(ePDFQueue."Entry No.");
                            UNTIL ePDFQueue.NEXT = 0;

                            IF GUIALLOWED THEN
                                Window.CLOSE;
                        END;
                    End;
                }
            }
            group(Lines)
            {
                action("Show Document")
                {
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Report;
                    trigger OnAction();
                    var
                        ePDFMgmt : Codeunit "ePDF Management";
                    begin
                        ePDFMgmt.ShowDocument("Document Code","Document No.");
                    end;
                }
                action("Show Recipient")
                {
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Report;
                    trigger OnAction();
                    var
                        ePDFMgmt : Codeunit "ePDF Management";
                    begin
                        ePDFMgmt.ShowRecipient("Document Code","Document No.");
                    end;
                }
                action("Show Email Addresses")
                {
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Report;
                    RunObject = Page "ePDF Email Addresses";
                    RunPageLink = "Document Code"=FIELD("Document Code"),"Entity Type"=FIELD("Entity Type"),"Entity No."= FIELD("Entity No.");
                    trigger OnAction();
                    var
                    begin
                    end;
                }
            }
        }
    }
}