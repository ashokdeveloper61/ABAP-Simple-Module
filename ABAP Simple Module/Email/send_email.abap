*&---------------------------------------------------------------------*
*& Report  ZSEND_EMAIL
*&
*&---------------------------------------------------------------------*
*& ABAP Sample Code
*& Send email with CL_BCS
*&
*& Mauricio Lauffer
*& http://www.linkedin.com/in/mauriciolauffer
*&
*& This sample explains how to send an email using class: CL_BCS
*&
*&---------------------------------------------------------------------*

REPORT zsend_email.


CONSTANTS:
  gc_subject  TYPE so_obj_des VALUE 'ABAP Email with CL_BCS', " Email subject
  gc_email_to TYPE adr6-smtp_addr VALUE 'frodo.baggins@lotr.com', " Valid email
  gc_text     TYPE soli VALUE 'Hello world! My first ABAP email!', " Text used into the email body
  gc_type_raw TYPE so_obj_tp VALUE 'RAW'. " Email type

DATA:
  gt_text          TYPE soli_tab, " Table which contains email body text
  gv_sent_to_all   TYPE os_boolean, " Receive the information if email was sent
  gv_error_message TYPE string, " Used to get the error message
  go_send_request  TYPE REF TO cl_bcs, " Email object
  go_recipient     TYPE REF TO if_recipient_bcs, " Who will receive the email
  go_sender        TYPE REF TO cl_sapuser_bcs, " Who is sending the email
  go_document      TYPE REF TO cl_document_bcs, " Email body
  gx_bcs_exception TYPE REF TO cx_bcs.


TRY.
    "Create send request
    go_send_request = cl_bcs=>create_persistent( ).

    "Email FROM...
    go_sender = cl_sapuser_bcs=>create( sy-uname ).
    "Add sender to send request
    go_send_request->set_sender( i_sender = go_sender ).

    "Email TO...
    go_recipient = cl_cam_address_bcs=>create_internet_address( gc_email_to ).
    "Add recipient to send request
    go_send_request->add_recipient(
      EXPORTING
        i_recipient = go_recipient
        i_express   = abap_true
    ).

    "Email BODY
    APPEND gc_text TO gt_text.
    go_document = cl_document_bcs=>create_document(
                    i_type    = gc_type_raw
                    i_text    = gt_text
                    i_length  = '12'
                    i_subject = gc_subject ).
    "Add document to send request
    go_send_request->set_document( go_document ).

    "Send email and get the result
    gv_sent_to_all = go_send_request->send( i_with_error_screen = abap_true ).
    IF gv_sent_to_all = abap_true.
      WRITE 'Email sent!'.
    ENDIF.

    "Commit to send email
    COMMIT WORK.

    "Exception handling
  CATCH cx_bcs INTO gx_bcs_exception.
    gv_error_message = gx_bcs_exception->get_text( ).
    WRITE gv_error_message.
ENDTRY.