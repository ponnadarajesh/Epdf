codeunit 7000000 "ePDF Management"
{
    var
        SourceCodeSetup: Record "Source Code Setup";
        ePDFSetup: Record "ePDF Setup";
        ePDFDocSetup: Record "ePDF Document Setup";
        ePDFEmailAddr: Record "ePDF Email Address";
        recPurchHeader: Record "Purchase Header";
        recVend: Record "Vendor";
        recSalesHeader: Record "Sales Header";
        recCust: Record Customer;
        recPurchRcptHeader: Record "Purch. Rcpt. Header";
        recPurchInvHeader: Record "Purch. Inv. Header";
        recPurchReturnShipHeader: Record "Return Shipment Header";
        recPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        recSalesShipHeader: Record "Sales Shipment Header";
        recSalesInvHeader: Record "Sales Invoice Header";
        recSalesRetRcptHeader: Record "Return Receipt Header";
        recSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        recGenJnlLine: Record "Gen. Journal Line";
        recIssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        recIssuedReminderHeader: Record "Issued Reminder Header";
        recTransferHeader: Record "Transfer Header";
        recLoc: Record Location;
        SMTPMail: Codeunit "SMTP Mail";
        FileName: Text[250];
        EmailSent: Boolean;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedEntry: Record "Vendor Ledger Entry";
        Cust1: Record Customer;
        Vend1: Record Vendor;
        CustDateFilter: Date;
        VendDateFilter: Date;
        PaymentTemplate: Code[20];
        PaymentBatch: Code[20];
        EmailInStream: InStream;
        EmailOutStream: OutStream;
        XMLParameters: Text;
        TempTable: Record TempBlob temporary;

    procedure SendDocument(DocCode: Code[10]; DocNo: code[20]): Boolean
    var
        //ePDFDocSetup: Record "ePDF Document Setup";
        EmailSent: Boolean;
        QueueEntryNo: Integer;
    begin
        EmailSent := FALSE;

        IF NOT ePDFDocSetup.GET(DocCode) THEN
            ERROR('Could not find ePDF Document Setup for Document Code %1 .', DocCode);

        IF NOT ePDFDocSetup.Enable THEN
            ERROR('Document Code %1 is not enabled in ePDF Document Setup.', DocCode);

        QueueEntryNo := CreateDocQueue(DocCode, DocNo);
        IF NOT ePDFDocSetup."Use Batch Processing" THEN BEGIN
            CreatePDFandEmail(QueueEntryNo);
        END ELSE BEGIN
            //Else the CreatePdf & SendEmail will be called from the screen (ePDF Queue List) which'll send respective reports in a batch.
        END;

        EXIT(EmailSent);
    end;

    procedure CreateDocQueue(DocCode: Code[10]; DocNo: code[20]): Integer
    var
        ePDFQueue: Record "ePDF Queue";
        ePDFHistory: Record "ePDF History";
        EntryNo: Integer;
    begin
        IF NOT ePDFDocSetup.GET(DocCode) THEN
            ERROR('Could not find ePDF Document Setup for Document Code %1 .', DocCode);

        IF NOT CheckAttachmentExist(DocCode, DocNo) THEN
            EXIT;

        WITH ePDFQueue DO
        BEGIN
            RESET;
            IF FINDLAST THEN
                EntryNo := "Entry No." + 1
            ELSE
                EntryNo := 1;

            ePDFHistory.RESET;
            IF ePDFHistory.FINDLAST THEN
                IF EntryNo <= ePDFHistory."Entry No." THEN
                    EntryNo := ePDFHistory."Entry No." + 1;

            RESET;
            INIT;
            "Entry No." := EntryNo;
            "Document Code" := DocCode;
            "Document No." := DocNo;
            Description := ePDFDocSetup."Document Description";
            "Date Logged" := TODAY;
            "Time Logged" := TIME;
            "Logged By" := USERID;
            "PDF Path" := ePDFDocSetup."Default Path to Store PDF";
            INSERT(TRUE);

            IF InitializeRecordVariables(DocCode, DocNo) THEN BEGIN
                CASE DocCode OF
                    ePDFSetup."Purchase Order",
                    ePDFSetup."Purchase Invoice",
                    ePDFSetup."Purchase Quote",
                    ePDFSetup."Purchase Return Order",
                    ePDFSetup."Posted Purchase Receipt",
                    ePDFSetup."Posted Purchase Invoice",
                    ePDFSetup."Posted Purch Return Shipment",
                    ePDFSetup."Posted Purch Credit Memo",
                    ePDFSetup."Remittance Advice",
                    ePDFSetup."Vendor Statement" :
                BEGIN
                    "Entity Type" := ePDFQueue."Entity Type"::Vendor;
                    "Entity No." := recVend."No.";
                END;
                ePDFSetup."Sales Order",
                ePDFSetup."Sales Invoice",
                ePDFSetup."Sales Quote",
                ePDFSetup."Sales Return Order",
                ePDFSetup."Posted Sales Shipment",
                ePDFSetup."Posted Sales Invoice",
                ePDFSetup."Posted Sales Return Receipt",
                ePDFSetup."Posted Sales Credit Memo",
                ePDFSetup."Issued Finance Charge",
                ePDFSetup."Issued Reminder",
                ePDFSetup."Customer Statement" :
                BEGIN
                    "Entity Type" := ePDFQueue."Entity Type"::Customer;
                    "Entity No." := recCust."No.";
                END;
                ePDFSetup."Transfer Order" :
                BEGIN
                    "Entity Type" := ePDFQueue."Entity Type"::Location;
                    "Entity No." := recLoc.Code;
                END;
                END;
                MODIFY;
            END;
            EXIT("Entry No.");
        END;
    end;

    procedure CreatePDFandEmail(EntryNo: Integer)
    var
        ePDFQueue: Record "ePDF Queue";
        DocCode: code[10];
        DocNo: Code[20];
        EntityType: Option Customer,Vendor,Location;
    begin
        ePDFQueue.GET(EntryNo);
        DocCode := ePDFQueue."Document Code";
        DocNo := ePDFQueue."Document No.";
        IF NOT InitializeRecordVariables(DocCode, DocNo) THEN
            EXIT;

        IF NOT CheckAttachmentExist(DocCode, DocNo) THEN
            EXIT;

        CASE DocCode OF
        ePDFSetup."Purchase Order",
        ePDFSetup."Purchase Invoice",
        ePDFSetup."Purchase Quote",
        ePDFSetup."Purchase Return Order" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
        END;
        ePDFSetup."Posted Purchase Receipt" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
        END;
        ePDFSetup."Posted Purchase Invoice" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
        END;
        ePDFSetup."Posted Purch Return Shipment" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
        END;
        ePDFSetup."Posted Purch Credit Memo" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
        END;
        ePDFSetup."Remittance Advice" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            IF recGenJnlLine."Applies-to Doc. No." <> '' THEN BEGIN
                SetEmailStream(ePDFDocSetup."Related Report ID");
                IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                    SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
            END ELSE BEGIN
                SetEmailStream(ePDFDocSetup."Related Report ID");
                IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                    SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
            END;
        END;
        ePDFSetup."Vendor Statement" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Vendor, recVend."No.", recVend."E-Mail");
        END;
        ePDFSetup."Sales Order",
        ePDFSetup."Sales Invoice",
        ePDFSetup."Sales Quote",
        ePDFSetup."Sales Return Order" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Posted Sales Shipment" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Posted Sales Invoice" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Posted Sales Return Receipt" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Posted Sales Credit Memo" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Issued Finance Charge" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Issued Reminder" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Customer Statement" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Customer, recCust."No.", recCust."E-Mail");
        END;
        ePDFSetup."Transfer Order" :
        BEGIN
            FileName := CreateFileName(DocCode, DocNo);
            SetEmailStream(ePDFDocSetup."Related Report ID");
            IF REPORT.SaveAs(ePDFDocSetup."Related Report ID", XMLParameters, ReportFormat::Pdf, EmailOutStream) THEN
                SendEmail(DocCode, DocNo, EntityType::Location, recLoc.Code, recLoc."ePDF Receipt Email ID");
        END;
        END;

        PostToHistory(EntryNo);

    end;

    procedure CreateFileName(DocCode: Code[10]; DocNo: code[20]): text[250]
    var
        lvFileName: Text[250];
    begin
        lvFileName := ePDFDocSetup."Default Path to Store PDF" +
              DocCode + '_' +
              FORMAT(DATE2DMY(WORKDATE, 1)) + FORMAT(DATE2DMY(WORKDATE, 2)) + FORMAT(DATE2DMY(WORKDATE, 3)) +
              '_' + DocNo + '.pdf';

        EXIT(lvFileName);
    end;

    procedure SendEmail(DocCode: Code[10]; DocNo: Code[20]; pEntityType: Option Customer, Vendor, Location; pEntityNo: Code[20]; ToEmailAddr: Text[100])
    var
        LF: Char;
        CR: Char;
    begin
        LF := 10;
        CR := 13;

        SMTPMail.CreateMessage(ePDFSetup."Sender Name",
                            ePDFSetup."Sender Email ID",
                            '',
                            ePDFDocSetup."Email Subject",
                            '',
                            TRUE);
        ePDFEmailAddr.RESET;
        ePDFEmailAddr.SETRANGE("Document Code", DocCode);
        ePDFEmailAddr.SETRANGE("Entity Type", pEntityType);
        ePDFEmailAddr.SETRANGE("Entity No.", pEntityNo);
        IF ePDFEmailAddr.FINDSET OR(ToEmailAddr <> '') THEN BEGIN
            IF ePDFEmailAddr.FINDSET THEN BEGIN
                REPEAT
                    CASE ePDFEmailAddr."Address Type" OF
                        ePDFEmailAddr."Address Type"::"To" : SMTPMail.AddRecipients(ePDFEmailAddr.Address);
                ePDFEmailAddr."Address Type"::Cc : SMTPMail.AddCC(ePDFEmailAddr.Address);
                ePDFEmailAddr."Address Type"::Bcc : SMTPMail.AddBCC(ePDFEmailAddr.Address);
                END;
                UNTIL ePDFEmailAddr.NEXT = 0;
            END ELSE BEGIN
                SMTPMail.AddRecipients(ToEmailAddr);
            END;

            IF ePDFSetup."CC Email to Sender" THEN
                SMTPMail.AddCC(ePDFSetup."Sender Email ID");
            SMTPMail.AppendBody(ePDFDocSetup."Email Body 1");
            SMTPMail.AppendBody(FORMAT(CR, 0, '<CHAR>') + FORMAT(LF, 0, '<CHAR>'));
            //>>ePDF HBSML Add Line break in betwwen Email bodies
            SMTPMail.AppendBody(FORMAT('<br>'));
            SMTPMail.AppendBody(FORMAT('<br>'));
            //<<ePDF HBSML
            SMTPMail.AppendBody(ePDFDocSetup."Email Body 2");
            SMTPMail.AppendBody(FORMAT(CR, 0, '<CHAR>') + FORMAT(LF, 0, '<CHAR>'));
            //>>ePDF HBSML Add Line break in betwwen Email bodies
            SMTPMail.AppendBody(FORMAT('<br>'));
            SMTPMail.AppendBody(FORMAT('<br>'));
            //<<ePDF HBSML
            SMTPMail.AppendBody(ePDFDocSetup."Email Body 3");
            SMTPMail.AppendBody(FORMAT(CR, 0, '<CHAR>') + FORMAT(LF, 0, '<CHAR>'));
            //>>ePDF HBSML Add Line break in betwwen Email bodies
            SMTPMail.AppendBody(FORMAT('<br>'));
            SMTPMail.AppendBody(FORMAT('<br>'));
            //<<ePDF HBSML
            SMTPMail.AppendBody(ePDFDocSetup."Email Body 4");
            SMTPMail.AddAttachmentStream(EmailInStream, FileName); ;
            SMTPMail.Send();
            EmailSent := TRUE;
        END ELSE BEGIN
            ERROR('No Email IDs defined');
        END;
    end;

    procedure PostToHistory(EntryNo: Integer)
    var
        ePDFQueue: Record "ePDF Queue";
        ePDFHistory: Record "ePDF History";
    begin
        ePDFQueue.GET(EntryNo);
        WITH ePDFHistory DO
        BEGIN
            RESET;
            INIT;
            TRANSFERFIELDS(ePDFQueue);
            "Entry No." := ePDFQueue."Entry No.";
            "PDF Path" := FileName;
            "Date Processed" := TODAY;
            "Time Processed" := TIME;
            "Processed By" := USERID;
            INSERT(TRUE);
        END;
        ePDFQueue.DELETE(TRUE);
    end;

    procedure ShowDocument(DocCode: Code[10]; DocNo: Code[20])
    begin
        IF NOT InitializeRecordVariables(DocCode, DocNo) THEN
            EXIT;

        IF ISSERVICETIER THEN BEGIN
            CASE DocCode OF
                ePDFSetup."Purchase Order" :
                PAGE.RUNMODAL(PAGE::"Purchase Order", recPurchHeader);
            ePDFSetup."Purchase Invoice" :
                PAGE.RUNMODAL(PAGE::"Purchase Invoice", recPurchHeader);
            ePDFSetup."Purchase Quote" :
                PAGE.RUNMODAL(PAGE::"Purchase Quote", recPurchHeader);
            ePDFSetup."Purchase Return Order" :
                PAGE.RUNMODAL(PAGE::"Purchase Return Order", recPurchHeader);
            ePDFSetup."Posted Purchase Receipt" :
                PAGE.RUNMODAL(PAGE::"Posted Purchase Receipt", recPurchRcptHeader);
            ePDFSetup."Posted Purchase Invoice" :
                PAGE.RUNMODAL(PAGE::"Posted Purchase Invoice", recPurchInvHeader);
            ePDFSetup."Posted Purch Return Shipment" :
                PAGE.RUNMODAL(PAGE::"Posted Return Shipment", recPurchReturnShipHeader);
            ePDFSetup."Posted Purch Credit Memo" :
                PAGE.RUNMODAL(PAGE::"Posted Purchase Credit Memo", recPurchCrMemoHeader);
            ePDFSetup."Remittance Advice" :
                MESSAGE('Kindly go to respective Payment Journal batch to view the details of Document No. %1.', DocNo);
            ePDFSetup."Vendor Statement" :
                PAGE.RUNMODAL(PAGE::"Vendor Card", recVend);
            ePDFSetup."Sales Order" :
                PAGE.RUNMODAL(PAGE::"Sales Order", recSalesHeader);
            ePDFSetup."Sales Invoice" :
                PAGE.RUNMODAL(PAGE::"Sales Invoice", recSalesHeader);
            ePDFSetup."Sales Quote" :
                PAGE.RUNMODAL(PAGE::"Sales Quote", recSalesHeader);
            ePDFSetup."Sales Return Order" :
                PAGE.RUNMODAL(PAGE::"Sales Return Order", recSalesHeader);
            ePDFSetup."Posted Sales Shipment" :
                PAGE.RUNMODAL(PAGE::"Posted Sales Shipment", recSalesShipHeader);
            ePDFSetup."Posted Sales Invoice" :
                PAGE.RUNMODAL(PAGE::"Posted Sales Invoice", recSalesInvHeader);
            ePDFSetup."Posted Sales Return Receipt" :
                PAGE.RUNMODAL(PAGE::"Posted Return Receipt", recSalesRetRcptHeader);
            ePDFSetup."Posted Sales Credit Memo" :
                PAGE.RUNMODAL(PAGE::"Posted Sales Credit Memo", recSalesCrMemoHeader);
            ePDFSetup."Issued Finance Charge" :
                PAGE.RUNMODAL(PAGE::"Issued Finance Charge Memo", recIssuedFinChargeMemoHeader);
            ePDFSetup."Issued Reminder" :
                PAGE.RUNMODAL(PAGE::"Issued Reminder", recIssuedReminderHeader);
            ePDFSetup."Customer Statement" :
                PAGE.RUNMODAL(PAGE::"Customer Card", recCust);
            ePDFSetup."Transfer Order" :
                PAGE.RUNMODAL(PAGE::"Transfer Order", recTransferHeader);
            END;
        END;
    end;

    procedure ShowRecipient(DocCode: Code[10]; DocNo: Code[20])
    begin
        IF NOT InitializeRecordVariables(DocCode, DocNo) THEN
            EXIT;

        IF ISSERVICETIER THEN BEGIN
            CASE DocCode OF
                ePDFSetup."Purchase Order",
                ePDFSetup."Purchase Invoice",
                ePDFSetup."Purchase Quote",
                ePDFSetup."Purchase Return Order",
                ePDFSetup."Posted Purchase Receipt",
                ePDFSetup."Posted Purchase Invoice",
                ePDFSetup."Posted Purch Return Shipment",
                ePDFSetup."Posted Purch Credit Memo",
                ePDFSetup."Remittance Advice",
                ePDFSetup."Vendor Statement" :
                PAGE.RUNMODAL(PAGE::"Vendor Card", recVend);
            ePDFSetup."Sales Order",
                ePDFSetup."Sales Invoice",
                ePDFSetup."Sales Quote",
                ePDFSetup."Sales Return Order",
                ePDFSetup."Posted Sales Shipment",
                ePDFSetup."Posted Sales Invoice",
                ePDFSetup."Posted Sales Return Receipt",
                ePDFSetup."Posted Sales Credit Memo",
                ePDFSetup."Issued Finance Charge",
                ePDFSetup."Issued Reminder",
                ePDFSetup."Customer Statement" :
                PAGE.RUNMODAL(PAGE::"Customer Card", recCust);
            ePDFSetup."Transfer Order" :
                PAGE.RUNMODAL(PAGE::"Location Card", recLoc);
            END;
        END;
    end;

    procedure InitializeRecordVariables(DocCode: Code[10]; DocNo: Code[20]): Boolean
    var
        returnvalue: Boolean;
    begin
        returnvalue := FALSE;
        ePDFSetup.GET;
        ePDFDocSetup.GET(DocCode);
        SourceCodeSetup.GET;
        CASE DocCode OF
        ePDFSetup."Purchase Order" :
        BEGIN
            recPurchHeader.RESET;
            recPurchHeader.SETRANGE("Document Type", recPurchHeader."Document Type"::Order);
            recPurchHeader.SETRANGE("No.", DocNo);
            IF recPurchHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Purchase Invoice" :
        BEGIN
            recPurchHeader.RESET;
            recPurchHeader.SETRANGE("Document Type", recPurchHeader."Document Type"::Invoice);
            recPurchHeader.SETRANGE("No.", DocNo);
            IF recPurchHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Purchase Quote" :
        BEGIN
            recPurchHeader.RESET;
            recPurchHeader.SETRANGE("Document Type", recPurchHeader."Document Type"::Quote);
            recPurchHeader.SETRANGE("No.", DocNo);
            IF recPurchHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Purchase Return Order" :
        BEGIN
            recPurchHeader.RESET;
            recPurchHeader.SETRANGE("Document Type", recPurchHeader."Document Type"::"Return Order");
            recPurchHeader.SETRANGE("No.", DocNo);
            IF recPurchHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Posted Purchase Receipt" :
        BEGIN
            recPurchRcptHeader.RESET;
            recPurchRcptHeader.SETRANGE("No.", DocNo);
            IF recPurchRcptHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchRcptHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Posted Purchase Invoice" :
        BEGIN
            recPurchInvHeader.RESET;
            recPurchInvHeader.SETRANGE("No.", DocNo);
            IF recPurchInvHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchInvHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Posted Purch Return Shipment" :
        BEGIN
            recPurchReturnShipHeader.RESET;
            recPurchReturnShipHeader.SETRANGE("No.", DocNo);
            IF recPurchReturnShipHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchReturnShipHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Posted Purch Credit Memo" :
        BEGIN
            recPurchCrMemoHeader.RESET;
            recPurchCrMemoHeader.SETRANGE("No.", DocNo);
            IF recPurchCrMemoHeader.FINDFIRST THEN
                returnvalue := recVend.GET(recPurchCrMemoHeader."Buy-from Vendor No.");
        END;
        ePDFSetup."Remittance Advice" :
        BEGIN
            recGenJnlLine.RESET;
            recGenJnlLine.SETRANGE("Source Code", SourceCodeSetup."Payment Journal");
            recGenJnlLine.SETRANGE("Journal Template Name", PaymentTemplate);                                  //HBSRP
            recGenJnlLine.SETRANGE("Journal Batch Name", PaymentBatch);
            recGenJnlLine.SETRANGE("Account No.", DocNo);
            IF recGenJnlLine.FINDSET THEN
                returnvalue := recVend.GET(DocNo);
        END;
        ePDFSetup."Vendor Statement" :
        BEGIN
            recVend.RESET;
            recVend.SETRANGE("No.", DocNo);
            returnvalue := recVend.FINDFIRST;
        END;
        ePDFSetup."Sales Order" :
        BEGIN
            recSalesHeader.RESET;
            recSalesHeader.SETRANGE("Document Type", recSalesHeader."Document Type"::Order);
            recSalesHeader.SETRANGE("No.", DocNo);
            IF recSalesHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Sales Invoice" :
        BEGIN
            recSalesHeader.RESET;
            recSalesHeader.SETRANGE("Document Type", recSalesHeader."Document Type"::Invoice);
            recSalesHeader.SETRANGE("No.", DocNo);
            IF recSalesHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Sales Quote" :
        BEGIN
            recSalesHeader.RESET;
            recSalesHeader.SETRANGE("Document Type", recSalesHeader."Document Type"::Quote);
            recSalesHeader.SETRANGE("No.", DocNo);
            IF recSalesHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Sales Return Order" :
        BEGIN
            recSalesHeader.RESET;
            recSalesHeader.SETRANGE("Document Type", recSalesHeader."Document Type"::"Return Order");
            recSalesHeader.SETRANGE("No.", DocNo);
            IF recSalesHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Posted Sales Shipment" :
        BEGIN
            recSalesShipHeader.RESET;
            recSalesShipHeader.SETRANGE("No.", DocNo);
            IF recSalesShipHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesShipHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Posted Sales Invoice" :
        BEGIN
            recSalesInvHeader.RESET;
            recSalesInvHeader.SETRANGE("No.", DocNo);
            IF recSalesInvHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesInvHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Posted Sales Return Receipt" :
        BEGIN
            recSalesRetRcptHeader.RESET;
            recSalesRetRcptHeader.SETRANGE("No.", DocNo);
            IF recSalesRetRcptHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesRetRcptHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Posted Sales Credit Memo" :
        BEGIN
            recSalesCrMemoHeader.RESET;
            recSalesCrMemoHeader.SETRANGE("No.", DocNo);
            IF recSalesCrMemoHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recSalesCrMemoHeader."Sell-to Customer No.");
        END;
        ePDFSetup."Issued Finance Charge" :
        BEGIN
            recIssuedFinChargeMemoHeader.RESET;
            recIssuedFinChargeMemoHeader.SETRANGE("No.", DocNo);
            IF recIssuedFinChargeMemoHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recIssuedFinChargeMemoHeader."Customer No.");
        END;
        ePDFSetup."Issued Reminder" :
        BEGIN
            recIssuedReminderHeader.RESET;
            recIssuedReminderHeader.SETRANGE("No.", DocNo);
            IF recIssuedReminderHeader.FINDFIRST THEN
                returnvalue := recCust.GET(recIssuedReminderHeader."Customer No.");
        END;
        ePDFSetup."Customer Statement" :
        BEGIN
            recCust.RESET;
            recCust.SETRANGE("No.", DocNo);
            returnvalue := recCust.FINDFIRST;
        END;
        ePDFSetup."Transfer Order" :
        BEGIN
            recTransferHeader.RESET;
            recTransferHeader.SETRANGE("No.", DocNo);
            IF recTransferHeader.FINDFIRST THEN
                returnvalue := recLoc.GET(recTransferHeader."Transfer-to Code");
        END;
        END;
        EXIT(returnvalue);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, true)]
    local procedure OnSalesPost_CreatePDF();
    VAR
        SalesHeader: Record "Sales Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SalesShptHdrNo: Code[20];
        RetRcpHdrNo: Code[20];
        SalesInvHdrNo: Code[20];
        SalesCrMemoHdrNo: Code[20];
        ePDF: Codeunit "ePDF Management";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        //HBSTG ePDF1.00 2014-06-11: Start >> Emailing Posted Sales Shipment, Invoice, Return Receipt and Credit Memo
        IF ePDFSetup.GET THEN BEGIN
            IF SalesHeader.Ship
            AND(SalesHeader."Document Type" IN [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order])
            AND(ePDFSetup."Posted Sales Shipment" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Sales Shipment");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recCust.RESET;
                    IF recCust.GET(SalesHeader."Sell-to Customer No.") THEN
                        IF recCust."ePDF Email" THEN
                            ePDF.SendDocument(ePDFSetup."Posted Sales Shipment", SalesShptHdrNo);
                END;
            END;
            IF SalesHeader.Invoice
            AND(SalesHeader."Document Type" IN [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order])
            AND(ePDFSetup."Posted Sales Invoice" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Sales Invoice");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recCust.RESET;
                    IF recCust.GET(SalesHeader."Sell-to Customer No.") THEN
                        IF recCust."ePDF Email" THEN BEGIN
                            //ePDF.SendDocument(ePDFSetup."Posted Sales Invoice",SalesInvHdrNo);
                            //ePDF.SendDocument(ePDFSetup."Posted Sales Invoice",SalesInvHdrNo);
                            // HBS VK #10209 >>
                            SalesInvoiceLine.SETRANGE("Document No.", SalesInvHdrNo);
                            SalesInvoiceLine.SETFILTER("Job No.", '<>%1', '');
                            IF SalesInvoiceLine.ISEMPTY THEN
                                // HBS VK #10209 <<
                                ePDF.SendDocument(ePDFSetup."Posted Sales Invoice", SalesInvHdrNo)
                            // HBS VK #10209 >>
                            ELSE
                                ePDF.SendDocument(ePDFSetup."Posted Service Sales Invoice", SalesInvHdrNo);
                            // HBS VK #10209 <<
                        END;
                END;
            END;
            IF SalesHeader.Receive
            AND(SalesHeader."Document Type" IN [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"])
            AND(ePDFSetup."Posted Sales Return Receipt" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Sales Return Receipt");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recCust.RESET;
                    IF recCust.GET(SalesHeader."Sell-to Customer No.") THEN
                        IF recCust."ePDF Email" THEN
                            ePDF.SendDocument(ePDFSetup."Posted Sales Return Receipt", RetRcpHdrNo);
                END;
            END;
            IF SalesHeader.Invoice
            AND(SalesHeader."Document Type" IN [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"])
            AND(ePDFSetup."Posted Sales Credit Memo" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Sales Credit Memo");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recCust.RESET;
                    IF recCust.GET(SalesHeader."Sell-to Customer No.") THEN
                        IF recCust."ePDF Email" THEN
                            ePDF.SendDocument(ePDFSetup."Posted Sales Credit Memo", SalesCrMemoHdrNo);
                END;
            END;
        END;
        //HBSTG ePDF1.00 2014-06-11: End <<
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, true)]
    local procedure OnPurchPost_CreatePDF();
    var
        PurchaseHeader: Record "Purchase Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PurchRcpHdrNo: Code[20];
        RetShptHdrNo: Code[20];
        PurchInvHdrNo: Code[20];
        PurchCrMemoHdrNo: Code[20];
        ePDF: Codeunit "ePDF Management";
    begin
        //HBSTG ePDF1.00 2014-06-11: Start >> Emailing Posted Purchase Receipt, Invoice, Return Shipment and Credit Memo
        IF ePDFSetup.GET THEN BEGIN
            IF PurchaseHeader.Receive
            AND(PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::Order])
            AND(ePDFSetup."Posted Purchase Receipt" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Purchase Receipt");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recVend.RESET;
                    IF recVend.GET(PurchaseHeader."Buy-from Vendor No.") THEN
                        IF recVend."ePDF Email" THEN
                            ePDF.SendDocument(ePDFSetup."Posted Purchase Receipt", PurchRcpHdrNo);
                END;
            END;
            IF PurchaseHeader.Invoice
            AND(PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::Order])
            AND(ePDFSetup."Posted Purchase Invoice" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Purchase Invoice");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recVend.RESET;
                    IF recVend.GET(PurchaseHeader."Buy-from Vendor No.") THEN
                        IF recVend."ePDF Email" THEN
                            //ePDF1.01>>
                            IF recVend."ePDF Email - RCTI" THEN                                                    //ReSRP #10850 2017-10-27:
                                                                                                                   //IF PurchaseHeader."RCTI Invoice" THEN                                                //ReSRP #10850 2017-10-27:  
                                                                                                                   //ePDF1.01<<
                                ePDF.SendDocument(ePDFSetup."Posted Purchase Invoice", PurchInvHdrNo);
                END;
            END;
            IF PurchaseHeader.Ship
            AND(PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"])
            AND(ePDFSetup."Posted Purch Return Shipment" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Purch Return Shipment");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recVend.RESET;
                    IF recVend.GET(PurchaseHeader."Buy-from Vendor No.") THEN
                        IF recVend."ePDF Email" THEN
                            ePDF.SendDocument(ePDFSetup."Posted Purch Return Shipment", RetShptHdrNo);
                END;
            END;
            IF PurchaseHeader.Invoice
            AND(PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"])
            AND(ePDFSetup."Posted Purch Credit Memo" <> '') THEN BEGIN
                ePDFDocSetup.GET(ePDFSetup."Posted Purch Credit Memo");
                IF ePDFDocSetup.Enable THEN BEGIN
                    recVend.RESET;
                    IF recVend.GET(PurchaseHeader."Buy-from Vendor No.") THEN
                        IF recVend."ePDF Email" THEN
                            ePDF.SendDocument(ePDFSetup."Posted Purch Credit Memo", PurchCrMemoHdrNo);
                END;
            END;
        END;
        //HBSTG ePDF1.00 2014-06-11: End <<
    end;

    Procedure CheckAttachmentExist(DocCode: Code[10]; DocNo: Code[20]): Boolean
    begin
        ePDFSetup.GET;
        IF ePDFSetup."Stmt Print All With Entries" THEN BEGIN
            IF(DocCode = ePDFSetup."Customer Statement") THEN BEGIN
                IF ePDFSetup."Stmt Date Filter" = '' THEN
                    EVALUATE(CustDateFilter, FORMAT(CALCDATE('CM', WORKDATE)))
                ELSE
                    EVALUATE(CustDateFilter, ePDFSetup."Stmt Date Filter");
                CustLedgerEntry.RESET;
                CustLedgerEntry.SETRANGE("Customer No.", DocNo);
                CustLedgerEntry.SETRANGE(Open, TRUE);
                CustLedgerEntry.SETRANGE("Posting Date", 0D, CustDateFilter);
                IF NOT CustLedgerEntry.FINDFIRST THEN
                    EXIT(FALSE);
            END;
        END;

        IF ePDFSetup."Stmt Print All With Balance" THEN BEGIN
            IF(DocCode = ePDFSetup."Customer Statement") THEN BEGIN
                IF ePDFSetup."Stmt Date Filter" = '' THEN
                    EVALUATE(CustDateFilter, FORMAT(CALCDATE('CM', WORKDATE)))
                ELSE
                    EVALUATE(CustDateFilter, ePDFSetup."Stmt Date Filter");
                Cust1.RESET;
                Cust1.SETRANGE("No.", DocNo);
                Cust1.SETRANGE("Date Filter", 0D, CustDateFilter);
                IF Cust1.FINDFIRST THEN BEGIN
                    Cust1.CALCFIELDS("Net Change");
                    IF Cust1."Net Change" = 0 THEN
                        EXIT(FALSE);
                END;
            END;
        END;

        IF ePDFSetup."V Stmt Print All With Entries" THEN BEGIN
            IF DocCode = ePDFSetup."Vendor Statement" THEN BEGIN
                IF ePDFSetup."V Stmt Date Filter" = '' THEN
                    EVALUATE(VendDateFilter, FORMAT(CALCDATE('CM', WORKDATE)))
                ELSE
                    EVALUATE(VendDateFilter, ePDFSetup."V Stmt Date Filter");
                VendorLedEntry.RESET;
                VendorLedEntry.SETRANGE("Vendor No.", DocNo);
                VendorLedEntry.SETRANGE(Open, TRUE);
                VendorLedEntry.SETRANGE("Posting Date", 0D, VendDateFilter);
                IF NOT VendorLedEntry.FINDFIRST THEN
                    EXIT(FALSE);
            END;
        END;
        IF ePDFSetup."V Stmt Print All With Balance" THEN BEGIN
            IF DocCode = ePDFSetup."Vendor Statement" THEN BEGIN
                IF ePDFSetup."V Stmt Date Filter" = '' THEN
                    EVALUATE(VendDateFilter, FORMAT(CALCDATE('CM', WORKDATE)))
                ELSE
                    EVALUATE(VendDateFilter, ePDFSetup."V Stmt Date Filter");

                Vend1.RESET;
                Vend1.SETRANGE("No.", DocNo);
                Vend1.SETRANGE("Date Filter", 0D, VendDateFilter);
                IF Vend1.FINDFIRST THEN BEGIN
                    Vend1.CALCFIELDS("Net Change");
                    IF Vend1."Net Change" = 0 THEN
                        EXIT(FALSE);
                END;
            END;
        END;
        EXIT(TRUE);
    End;

    Procedure SetPaymentJnlTemplate_Batch(pPaymentTemplate: Code[20]; pPaymentBatch: Code[20])
    begin
    End;

    Procedure SetEmailStream(pReportID: Integer)
    begin
        XMLParameters := Report.RunRequestPage(pReportID);
        TempTable.Blob.CREATEINSTREAM(EmailInStream, TextEncoding::UTF8);
        TempTable.Blob.CREATEOUTSTREAM(EmailOutStream, TextEncoding::UTF8);
    End;

}