create or replace package Hdr_Pref is
  ----------------------------------------------------------------------------------------------------  
  type Aat_Number is table of number index by pls_integer;
  ----------------------------------------------------------------------------------------------------
  -- report template type: across filials, across quizs, across documents
  ----------------------------------------------------------------------------------------------------
  c_Across_Filials   constant varchar2(1) := 'F';
  c_Across_Quizs     constant varchar2(1) := 'Q';
  c_Across_Documents constant varchar2(1) := 'D';
end Hdr_Pref;
/
