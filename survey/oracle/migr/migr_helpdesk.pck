create or replace package Migr_Helpdesk is
  ----------------------------------------------------------------------------------------------------  
  Procedure Migration_Execute(i_Company_Id number);
end Migr_Helpdesk;
/
create or replace package body Migr_Helpdesk is
  g_Company_Id        number;
  g_Quiz_Set_Group_Id number;
  g_Quiz_Set_Ids      Array_Number;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Users is
    r_User Md_Users%rowtype;
  begin
    for r in (select *
                from Old_Md_Users t
               where t.User_Id not in (1, 2, 3))
    loop
      r_User.Company_Id := g_Company_Id;
      r_User.User_Id    := Md_Next.Person_Id;
      r_User.Name       := r.Name;
      r_User.Login      := Md_Util.Make_Login(i_Company_Id => g_Company_Id, i_Login => r.Login);
      r_User.Password   := r.Password;
      r_User.State      := r.State;
      r_User.User_Kind  := Md_Pref.c_Uk_Normal;
    
      Md_Api.Person_Save(i_Company_Id => g_Company_Id,
                         i_Person_Id  => r_User.User_Id,
                         i_Name       => r.Name,
                         Is_Legal     => false);
    
      Md_Api.User_Save(r_User);
    
      z_Migr_Users.Insert_One(i_Old_User_Id => r.User_Id, i_New_User_Id => r_User.User_Id);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_User_Filials is
  begin
    for r in (select *
                from Old_Md_User_Filials t
               where t.User_Id not in (1, 2, 3))
    loop
      Md_Api.User_Add_Filial(i_Company_Id => g_Company_Id,
                             i_User_Id    => z_Migr_Users.Load(i_Old_User_Id => r.User_Id).New_User_Id,
                             i_Filial_Id  => z_Migr_Filials.Load(i_Old_Filial_Id => r.Filial_Id).New_Filial_Id);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Filials is
    v_Filial_Id number;
    r_Filial    Md_Filials%rowtype;
  begin
    for r in (select *
                from Old_Md_Filials t
               where t.Filial_Id <> 0)
    loop
      v_Filial_Id := Md_Next.Person_Id;
    
      r_Filial.Company_Id := g_Company_Id;
      r_Filial.Filial_Id  := v_Filial_Id;
      r_Filial.Name       := r.Name;
      r_Filial.State      := r.State;
    
      Md_Api.Person_Save(i_Company_Id => r_Filial.Company_Id,
                         i_Person_Id  => r_Filial.Filial_Id,
                         i_Name       => r_Filial.Name,
                         Is_Legal     => true);
    
      Md_Api.Filial_Save(r_Filial);
    
      z_Migr_Filials.Insert_One(i_Old_Filial_Id => r.Filial_Id, i_New_Filial_Id => v_Filial_Id);
    end loop;
  
    Migr_Users;
    Migr_User_Filials;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Quiz_Set_Group is
  begin
    g_Quiz_Set_Group_Id := Hd_Next.Quiz_Set_Group_Id;
  
    z_Hd_Quiz_Set_Groups.Insert_One(i_Company_Id        => g_Company_Id,
                                    i_Quiz_Set_Group_Id => g_Quiz_Set_Group_Id,
                                    i_Name              => 'survey',
                                    i_State             => 'A');
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Insert_Quiz_Set(i_Name varchar2) return number is
    r_Quiz_Set Hd_Quiz_Sets%rowtype;
  begin
    r_Quiz_Set.Company_Id  := g_Company_Id;
    r_Quiz_Set.Quiz_Set_Id := Hd_Next.Quiz_Set_Id;
    r_Quiz_Set.Name        := i_Name;
    r_Quiz_Set.State       := 'A';
    z_Hd_Quiz_Sets.Insert_Row(r_Quiz_Set);
  
    return r_Quiz_Set.Quiz_Set_Id;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Quiz_Sets is
    v_Quiz_Names Array_Varchar2;
  begin
    g_Quiz_Set_Ids := Array_Number();
    g_Quiz_Set_Ids.Extend(5);
  
    v_Quiz_Names := Array_Varchar2('Основной',
                                   'Дополнительно',
                                   'Вопросы',
                                   'Действие оператора',
                                   'Мероприятие');
  
    for i in 1 .. v_Quiz_Names.Count
    loop
      g_Quiz_Set_Ids(i) := Insert_Quiz_Set(v_Quiz_Names(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Quiz_Set_Group_Binds is
  begin
    for i in 1 .. g_Quiz_Set_Ids.Count
    loop
      z_Hd_Quiz_Set_Group_Binds.Insert_One(i_Company_Id        => g_Company_Id,
                                           i_Quiz_Set_Group_Id => g_Quiz_Set_Group_Id,
                                           i_Quiz_Set_Id       => g_Quiz_Set_Ids(i),
                                           i_Order_No          => i);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Insert_Quiz
  (
    i_Quiz_Id         number,
    i_Name            varchar2,
    i_Data_Kind       varchar2,
    i_Quiz_Kind       varchar2,
    i_Select_Multiple varchar2 := null,
    i_Select_Form     varchar2 := null,
    i_Min_Scale       number := null,
    i_Max_Scale       number := null
  ) is
  begin
  
    z_Hd_Quizs.Insert_One(i_Company_Id      => g_Company_Id,
                          i_Quiz_Id         => i_Quiz_Id,
                          i_Name            => i_Name,
                          i_State           => 'A',
                          i_Data_Kind       => i_Data_Kind,
                          i_Quiz_Kind       => i_Quiz_Kind,
                          i_Select_Multiple => i_Select_Multiple,
                          i_Select_Form     => i_Select_Form,
                          i_Min_Scale       => i_Min_Scale,
                          i_Max_Scale       => i_Max_Scale,
                          i_Is_Required     => 'N');
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Quiz_Set_Binds
  (
    i_Quiz_Set_Id number,
    i_Quiz_Ids    Array_Number
  ) is
  begin
    for i in 1 .. i_Quiz_Ids.Count
    loop
      z_Hd_Quiz_Set_Binds.Insert_One(i_Company_Id  => g_Company_Id,
                                     i_Quiz_Set_Id => i_Quiz_Set_Id,
                                     i_Quiz_Id     => i_Quiz_Ids(i),
                                     i_Order_No    => i);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Insert_Quiz_Option1
  (
    i_Quiz_Id  number,
    i_Name     varchar2,
    i_Order_No number := 1
  ) return number is
    v_Option_Id number := Hd_Next.Option_Id;
  begin
    z_Hd_Quiz_Options.Insert_One(i_Company_Id => g_Company_Id,
                                 i_Option_Id  => v_Option_Id,
                                 i_Quiz_Id    => i_Quiz_Id,
                                 i_Name       => i_Name,
                                 i_State      => 'A',
                                 i_Order_No   => i_Order_No);
  
    return v_Option_Id;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Insert_Quiz_Option2
  (
    i_Quiz_Id  number,
    i_Name     varchar2,
    i_Order_No number := 1
  ) is
    v_Option_Id number := Hd_Next.Option_Id;
  begin
    z_Hd_Quiz_Options.Insert_One(i_Company_Id => g_Company_Id,
                                 i_Option_Id  => v_Option_Id,
                                 i_Quiz_Id    => i_Quiz_Id,
                                 i_Name       => i_Name,
                                 i_State      => 'A',
                                 i_Order_No   => i_Order_No);
  
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Insert_Quiz_Options
  (
    i_Quiz_Id number,
    i_Options Array_Varchar2
  ) is
  begin
    for i in 1 .. i_Options.Count
    loop
      Insert_Quiz_Option2(i_Quiz_Id => i_Quiz_Id, i_Name => i_Options(i), i_Order_No => i);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Insert_Option_Quiz
  (
    i_Option_Id     number,
    i_Child_Quiz_Id number
  ) is
  begin
    z_Hd_Option_Quizs.Insert_One(i_Company_Id    => g_Company_Id,
                                 i_Option_Id     => i_Option_Id,
                                 i_Child_Quiz_Id => i_Child_Quiz_Id);
  end;
  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Main_Quizs is
    v_Quiz_Id   number;
    v_Option_Id number;
    v_Quiz_Ids  Array_Number := Array_Number();
  
    --------------------------------------------------             
    Procedure Add_Quiz_Id is
    begin
      v_Quiz_Ids.Extend;
      v_Quiz_Ids(v_Quiz_Ids.Count) := v_Quiz_Id;
    end;
  begin
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Номер звонка',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Дата и время',
                i_Data_Kind => Hd_Pref.c_Dk_Date,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Не Анонимно',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Check_Box);
    Add_Quiz_Id;
  
    --quiz options Анонимно
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id => v_Quiz_Id, i_Name => 'Да');
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Имя звонившего',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Номер звонящего',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Пол',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    --quiz options Пол
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Мужчина', 'Женщина'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Вид консультирования',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    --quiz options Вид консультирования
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Первично', 'Вторично'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Место нахождение звонящего / Регион',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Место нахождение звонящего / Регион
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Узбекистан',
                                                    'Казахстан',
                                                    'Россия'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'За рубежом',
                                       i_Order_No => 4);
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => '(За рубежом) место нахождение звонящего / Регион',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Способ обращения',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Способ обращения
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Лично',
                                                    'По телефону',
                                                    'Мессенджер',
                                                    'Через сайт',
                                                    'Интернет',
                                                    'Фейсбук'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Возраст',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Возраст
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('До 17',
                                                    '18-25',
                                                    '26-40',
                                                    '41-55',
                                                    '56-65',
                                                    'Старше 66'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Гражданство',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Гражданство
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Армения',
                                                    'Азербайджан',
                                                    'Белоруссия',
                                                    'Грузия',
                                                    'Туркменистан',
                                                    'Украина',
                                                    'Таджикистан',
                                                    'Казахстан',
                                                    'Киргизия',
                                                    'Узбекистан',
                                                    'Молдова'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другое гражданство',
                                       i_Order_No => 11);
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другое гражданство',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Национальность',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Национальность
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Узбек/узбечка',
                                                    'Русский/русская',
                                                    'Таджик/таджичка',
                                                    'Киргиз/киргизка',
                                                    'Казах/казашка',
                                                    'Уйгур/уйгурка',
                                                    'Татарин/татарка',
                                                    'Каракалпак/каракалпачка',
                                                    'Туркмен/туркменка',
                                                    'Кореец/кореянка'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другая национальность',
                                       i_Order_No => 11);
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другая национальность',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Migr_Quiz_Set_Binds(i_Quiz_Set_Id => g_Quiz_Set_Ids(1), i_Quiz_Ids => v_Quiz_Ids);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Additional_Quizs is
    v_Quiz_Id      number;
    v_Option_Id    number;
    v_Temp_Quiz_Id number;
    v_Quiz_Ids     Array_Number := Array_Number();
  
    --------------------------------------------------             
    Procedure Add_Quiz_Id is
    begin
      v_Quiz_Ids.Extend;
      v_Quiz_Ids(v_Quiz_Ids.Count) := v_Quiz_Id;
    end;
  begin
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Семейное положение',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Семейное положение
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Женат/Замужем',
                                                    'Холост/не замужем',
                                                    'Разведен/разведена',
                                                    'Вдовец/Вдова'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Наличие детей',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    --quiz options Наличие детей
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id, i_Options => Array_Varchar2('Да', 'Нет'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Образование',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Образование
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Высшее',
                                                    'Средне/школьное',
                                                    'Профессионально техническое',
                                                    'Нет'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Статус работы',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Статус работы
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Безработный',
                                                    'Работает',
                                                    'Пенсионер',
                                                    'Учащийся'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Профессия',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Профессия
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Учитель',
                                                    'Рабочий',
                                                    'Служащий',
                                                    'Медицинский работник',
                                                    'Учащийся',
                                                    'Сельскохозяйственный работник',
                                                    'Строитель',
                                                    'Нет профессии'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другая профессия',
                                       i_Order_No => 9);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другая профессия',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Откуда узнали о горячей линии',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Откуда узнали о горячей линии
    v_Option_Id    := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                          i_Name     => 'Объявления в прессе',
                                          i_Order_No => 1);
    v_Temp_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Temp_Quiz_Id,
                i_Name      => 'Объявления в прессе',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Temp_Quiz_Id);
  
    Insert_Quiz_Option2(i_Quiz_Id  => v_Quiz_Id,
                        i_Name     => 'Наружная реклама',
                        i_Order_No => 2);
  
    v_Option_Id    := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                          i_Name     => 'Телевидение',
                                          i_Order_No => 3);
    v_Temp_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Temp_Quiz_Id,
                i_Name      => 'Телевидение',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Temp_Quiz_Id);
  
    v_Option_Id    := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                          i_Name     => 'Радио',
                                          i_Order_No => 4);
    v_Temp_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Temp_Quiz_Id,
                i_Name      => 'Радио',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Temp_Quiz_Id);
  
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'СМС', i_Order_No => 5);
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'ННО', i_Order_No => 6);
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Знакомые', i_Order_No => 7);
    Insert_Quiz_Option2(i_Quiz_Id  => v_Quiz_Id,
                        i_Name     => 'Государственные органы',
                        i_Order_No => 8);
    Insert_Quiz_Option2(i_Quiz_Id  => v_Quiz_Id,
                        i_Name     => 'Правоохранительные органы',
                        i_Order_No => 9);
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Интернет', i_Order_No => 10);
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Метро', i_Order_No => 11);
    Insert_Quiz_Option2(i_Quiz_Id  => v_Quiz_Id,
                        i_Name     => 'РСИЦ "Истикболли Авлод"',
                        i_Order_No => 12);
    Insert_Quiz_Option2(i_Quiz_Id  => v_Quiz_Id,
                        i_Name     => 'Из раздаточного материала (брошюра/буклет.флаер)',
                        i_Order_No => 13);
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другие горячие линии',
                                       i_Order_No => 14);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другие горячие линии',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Migr_Quiz_Set_Binds(i_Quiz_Set_Id => g_Quiz_Set_Ids(2), i_Quiz_Ids => v_Quiz_Ids);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Question_Quizs is
    v_Quiz_Id   number;
    v_Option_Id number;
    v_Quiz_Ids  Array_Number := Array_Number();
  
    --------------------------------------------------             
    Procedure Add_Quiz_Id is
    begin
      v_Quiz_Ids.Extend;
      v_Quiz_Ids(v_Quiz_Ids.Count) := v_Quiz_Id;
    end;
  begin
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Страна назначения',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Страна назначения
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Армения',
                                                    'Азербайджан',
                                                    'Белоруссия',
                                                    'Грузия',
                                                    'Туркменистан',
                                                    'Украина',
                                                    'Таджикистан',
                                                    'Казахстан',
                                                    'Киргизия',
                                                    'Узбекистан',
                                                    'Молдова',
                                                    'ОАЭ',
                                                    'Турция',
                                                    'Китай',
                                                    'Таиланд',
                                                    'Россия',
                                                    'Германия',
                                                    'Индия',
                                                    'Израиль',
                                                    'Иран',
                                                    'Грузия',
                                                    'Пакистан',
                                                    'Польша',
                                                    'Корея',
                                                    'Япония',
                                                    'США',
                                                    'нет страны назначения'));
  
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другая страна назначения',
                                       i_Order_No => 28);
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другая страна назначения',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Информация о юридическом или физическом лице предоставляющим услуги по вывозу за рубеж или трудоустройству',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Информация о юридическом или физическом лице предоставляющим услуги по вывозу за рубеж или трудоустройству
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('официальные каналы',
                                                    'через родственников/ друзей/ знакомых',
                                                    'через посредническую фирму не имеющую лицензии',
                                                    'без посредников',
                                                    'нет информации'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Тип вопроса звонящего или основная проблема с которой обратился звонивший',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    --quiz options Тип вопроса звонящего или основная проблема с которой обратился звонивший
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('конкретные случае торговли людьми',
                                                    'о выезде с целью трудоустройства',
                                                    'о правилах пребывания за рубежом, внутри страны',
                                                    'взыскание з/п в Узбекистане',
                                                    'взыскание з/п зарубежом',
                                                    'дана инфо. о ходе кейса',
                                                    'инфо. принята',
                                                    'возвращение на родину',
                                                    'вопросы здоровья',
                                                    'социальные проблемы',
                                                    'проблемы семьи/ родственников',
                                                    'звонки партнеров',
                                                    'звонки представителей Правоохранительных органов',
                                                    'звонки представителей государственных органов',
                                                    'звонки журналистов',
                                                    'справочная информация',
                                                    'контакты государственных органов, консульств/ диаспор',
                                                    'советы по получению и восстановлению документов удостоверяющих личность',
                                                    'о въезде в Республику Узбекистан',
                                                    'о трудоустройстве в стране проживания',
                                                    'бевести пропавший',
                                                    'мошенничество и др. правонарушения',
                                                    'внутренняя миграция, нарушение трудого законодательста в Узбекистане.',
                                                    'взыскание заработной платы.',
                                                    'нарушение миграционных правил.',
                                                    'информация о деятельности и местонахождении организации',
                                                    'консультация/проверка наличия запрета на въезд в РФ',
                                                    'вопросы касательно домашнего насилия'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другой тип вопроса звонящего или основная проблема с которой обратился звонивший',
                                       i_Order_No => 29);
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другой тип вопроса звонящего или основная проблема с которой обратился звонивший',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Описание ситуации',
                i_Data_Kind => Hd_Pref.c_Dk_Long_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    Migr_Quiz_Set_Binds(i_Quiz_Set_Id => g_Quiz_Set_Ids(3), i_Quiz_Ids => v_Quiz_Ids);
  end;

  ---------------------------------------------------------------------------------------------------- 
  Procedure Consultant_Quizs(i_Option_Id number) is
    v_Quiz_Id     number;
    v_Quiz_Set_Id number;
    v_Option_Id   number;
    v_Quiz_Ids    Array_Number := Array_Number();
  
    --------------------------------------------------             
    Procedure Add_Quiz_Id is
    begin
      v_Quiz_Ids.Extend;
      v_Quiz_Ids(v_Quiz_Ids.Count) := v_Quiz_Id;
    end;
  begin
    v_Quiz_Set_Id := Insert_Quiz_Set('Консультация юриста');
    z_Hd_Option_Quiz_Sets.Insert_One(i_Company_Id        => g_Company_Id,
                                     i_Option_Id         => i_Option_Id,
                                     i_Child_Quiz_Set_Id => v_Quiz_Set_Id);
  
    --child quiz set quizs
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Виды оказания юридической помощи',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Рядом результаты',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Перенаправление в ПО',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Да');
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Нет', i_Order_No => 2);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Пернаправление из ПО',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Да');
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Нет', i_Order_No => 2);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Тип консультации',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('ЖТЛ',
                                                    'УМ',
                                                    'ЖДН',
                                                    'роз''ск/без вести пропавший',
                                                    'Пот''нциальный ЖТЛ',
                                                    'взы''кание з/п (Узбекистан)',
                                                    'взы''кание з/п (за рубежом)'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Виды эксплуатации',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Трудовая эксплуатация',
                                                    'Сексуальная Эксплуатация',
                                                    'Принудительный труд',
                                                    'ЖДН',
                                                    'Семейные проблемы',
                                                    'Социальные проблемы',
                                                    'другое Виды эксплуатации'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Открытие УД',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id, i_Options => Array_Varchar2('Да', 'Нет'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'отказ',
                                       i_Order_No => 3);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'отказ причина',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
  
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Migr_Quiz_Set_Binds(i_Quiz_Set_Id => v_Quiz_Set_Id, i_Quiz_Ids => v_Quiz_Ids);
  end;

  ----------------------------------------------------------------------------------------------------    
  Procedure Migr_Operator_Quizs is
    v_Quiz_Id          number;
    v_Option_Id        number;
    v_Parent_Option_Id number;
    v_Temp_Quiz_Id     number;
    v_Quiz_Ids         Array_Number := Array_Number();
  
    --------------------------------------------------             
    Procedure Add_Quiz_Id is
    begin
      v_Quiz_Ids.Extend;
      v_Quiz_Ids(v_Quiz_Ids.Count) := v_Quiz_Id;
    end;
  begin
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Действие оператора',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('дана информация',
                                                    'рекомендовано обратиться в по',
                                                    'дана консультация юриста',
                                                    'информация принята',
                                                    'дана информация по горячей линии',
                                                    'назначена встреча в офисе',
                                                    'принято заявление обращение о помощи'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Клиент получил следующую информацию',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Add_Quiz_Id;
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Перенаправлен в ПО',
                                                    'Правила выезда граждан за рубеж',
                                                    'О рисках нелегальной иммиграции',
                                                    'Информация о возможности легального трудоустройства',
                                                    'Справочная информация',
                                                    'Дана инфо. о ходе кейса',
                                                    'Инфо. принята',
                                                    'Конкретные советы женщинам которые собираются выезжать за границу',
                                                    'Опасность быть проданным в рабство',
                                                    'Основные принципы законодательства зарубежных стран в отношении нелегальных мигрантов',
                                                    'Адреса номера телефонов неправительственных организаций за рубежом которые предоставляют помощь ',
                                                    'Советы по получению и восстановлению документов удостоверяющих личность',
                                                    'Адреса и телефоны посольств /госорганов/ консульств/ диаспор',
                                                    'Вопросы обучения за рубежом',
                                                    'Вопросы миграции',
                                                    'Вопросы по расторжению и заключению брака с иностранцем',
                                                    'Вопросы семьи/родственников',
                                                    'Консультации связанные с вопросом освобождения жтл',
                                                    'О трудоустройстве в стране проживания',
                                                    'Принято заявление обращение о помощи',
                                                    'О деятельности и местонахождении центра',
                                                    'Консультация о наличии запрета на въезд',
                                                    'Консультация по случаям домашнего насилия',
                                                    'Перенаправлено в региональное отделение',
                                                    'другое Клиент получил следующую информацию'));
    v_Option_Id    := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                          i_Name     => 'Перенаправлен в ННО (партнепское)',
                                          i_Order_No => 25);
    v_Temp_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Temp_Quiz_Id,
                i_Name            => '(Регион) Перенаправлен в ННО (партнепское)',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Temp_Quiz_Id);
  
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'Консультация юриста',
                                       i_Order_No => 26);
  
    Consultant_Quizs(v_Option_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Было ли принято заявление на оказание помощи',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Add_Quiz_Id;
  
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Нет', i_Order_No => 2);
    v_Parent_Option_Id := Insert_Quiz_Option1(i_Quiz_Id => v_Quiz_Id, i_Name => 'Да');
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Номер заявления',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Дата заявления',
                i_Data_Kind => Hd_Pref.c_Dk_Date,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Ф.И.О. Заявителя',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Место проживания',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Паспортные данные Заявителя',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Паспортные данные ЖТЛ',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Количество мужчин',
                i_Data_Kind => Hd_Pref.c_Dk_Number,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Количество женщин',
                i_Data_Kind => Hd_Pref.c_Dk_Number,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Количество детей',
                i_Data_Kind => Hd_Pref.c_Dk_Number,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Статус заявления',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('ЖТЛ',
                                                    'Не ЖТЛ',
                                                    'УМ',
                                                    'Дети ЖТЛ',
                                                    'Дети УМ',
                                                    'ЖДН'));
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другая статус заявления',
                                       i_Order_No => 7);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другая статус заявления',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Характер заявления',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('возвращение на родину',
                                                    'восстановление документов',
                                                    'освобождение из трафика',
                                                    'встреча в аэропорту',
                                                    'юридическая консультация',
                                                    'другой характер заявления'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Описание оказанной помощи',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Помощь в возвращении',
                                                    'Подтверждение личности',
                                                    'Освобождение из трафика',
                                                    'Встреча в аэропорту',
                                                    'Восстановление удостоверяющих личность документов ( просьбы о восстановлении паспорта)',
                                                    'Отказался от помощи',
                                                    'другое описание оказанной помощи'));
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Конечный результат',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'Y',
                i_Select_Form     => Hd_Pref.c_Sf_Drop_Down);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id => v_Quiz_Id, i_Name => 'Вернулись');
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Дата возвращения',
                i_Data_Kind => Hd_Pref.c_Dk_Date,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Option2(i_Quiz_Id  => v_Quiz_Id,
                        i_Name     => 'Не вернулись',
                        i_Order_No => 2);
  
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другой конечный результат',
                                       i_Order_No => 3);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другой конечный результат',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Статус кейса',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Открыт');
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Закрыт', i_Order_No => 2);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Партнеры в возвращении',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('МОМ России',
                                                    'МОМ Казахстан',
                                                    'МО '));
  
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id  => v_Quiz_Id,
                                       i_Name     => 'другой партнеры в возвращении',
                                       i_Order_No => 4);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'другой партнеры в возвращении',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Было перенаправление в ПО',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Insert_Option_Quiz(i_Option_Id => v_Parent_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Option2(i_Quiz_Id => v_Quiz_Id, i_Name => 'Нет', i_Order_No => 2);
    v_Option_Id := Insert_Quiz_Option1(i_Quiz_Id => v_Quiz_Id, i_Name => 'Да');
    v_Quiz_Id   := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id         => v_Quiz_Id,
                i_Name            => 'Статус дела',
                i_Data_Kind       => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind       => Hd_Pref.c_Qk_Select,
                i_Select_Multiple => 'N',
                i_Select_Form     => Hd_Pref.c_Sf_Radio_Button);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Insert_Quiz_Options(i_Quiz_Id => v_Quiz_Id,
                        i_Options => Array_Varchar2('Открыт', 'Закрыт'));
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Описания дела',
                i_Data_Kind => Hd_Pref.c_Dk_Long_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Insert_Option_Quiz(i_Option_Id => v_Option_Id, i_Child_Quiz_Id => v_Quiz_Id);
  
    Migr_Quiz_Set_Binds(i_Quiz_Set_Id => g_Quiz_Set_Ids(4), i_Quiz_Ids => v_Quiz_Ids);
  end;

  ----------------------------------------------------------------------------------------------------    
  Procedure Migr_Event_Quizs is
    v_Quiz_Id  number;
    v_Quiz_Ids Array_Number := Array_Number();
  
    --------------------------------------------------             
    Procedure Add_Quiz_Id is
    begin
      v_Quiz_Ids.Extend;
      v_Quiz_Ids(v_Quiz_Ids.Count) := v_Quiz_Id;
    end;
  begin
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Проведенные мероприятия Дата',
                i_Data_Kind => Hd_Pref.c_Dk_Date,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Проведенные мероприятия Место',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Проведенные мероприятия Цель',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Рекламная компания Дата',
                i_Data_Kind => Hd_Pref.c_Dk_Date,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Рекламная компания Издание',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Рекламная компания Издание Количество',
                i_Data_Kind => Hd_Pref.c_Dk_Number,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Рекламная компания Радиостанция',
                i_Data_Kind => Hd_Pref.c_Dk_Short_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Рекламная компания Радиостанция Количество',
                i_Data_Kind => Hd_Pref.c_Dk_Number,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    v_Quiz_Id := Hd_Next.Quiz_Id;
    Insert_Quiz(i_Quiz_Id   => v_Quiz_Id,
                i_Name      => 'Текст',
                i_Data_Kind => Hd_Pref.c_Dk_Long_Text,
                i_Quiz_Kind => Hd_Pref.c_Qk_Manual);
    Add_Quiz_Id;
  
    Migr_Quiz_Set_Binds(i_Quiz_Set_Id => g_Quiz_Set_Ids(5), i_Quiz_Ids => v_Quiz_Ids);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migr_Quizs is
  begin
    Migr_Main_Quizs;
    Migr_Additional_Quizs;
    Migr_Question_Quizs;
    Migr_Operator_Quizs;
    Migr_Event_Quizs;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Quiz_Set_Group_Id return number is
    v_Quiz_Set_Group_Id number;
  begin
    select t.Quiz_Set_Group_Id
      into v_Quiz_Set_Group_Id
      from Hd_Quiz_Set_Groups t
     where t.Company_Id = g_Company_Id;
  
    return v_Quiz_Set_Group_Id;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Quiz_Answers
  (
    o_Survey_Quiz in out nocopy Hdf_Pref.Survey_Quiz_Rt,
    i_List        Arraylist
  ) is
    r_Quiz_Answer Hdf_Survey_Quiz_Answers%rowtype;
    v_Quiz_Answer Hdf_Pref.Survey_Quiz_Answer_Rt;
    v_List_Item   Hashmap;
  begin
    for i in 1 .. i_List.Count
    loop
      v_List_Item := Treat(i_List.r_Hashmap(i) as Hashmap);
    
      r_Quiz_Answer := z_Hdf_Survey_Quiz_Answers.To_Row(v_List_Item,
                                                        z.Sv_Quiz_Unit_Id,
                                                        z.Option_Id,
                                                        z.Answer);
      if r_Quiz_Answer.Sv_Quiz_Unit_Id is null then
        r_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      end if;
    
      Hdf_Util.Survey_Quiz_Answer_New(o_Survey_Quiz_Answer => v_Quiz_Answer,
                                      i_Sv_Quiz_Unit_Id    => r_Quiz_Answer.Sv_Quiz_Unit_Id,
                                      i_Option_Id          => r_Quiz_Answer.Option_Id,
                                      i_Answer             => r_Quiz_Answer.Answer);
    
      Hdf_Util.Survey_Quiz_Add_Answer(o_Survey_Quiz        => o_Survey_Quiz,
                                      i_Survey_Quiz_Answer => v_Quiz_Answer);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Survey_Quizs
  (
    o_Survey_Quiz_Set in out nocopy Hdf_Pref.Survey_Quiz_Set_Rt,
    i_List            Arraylist
  ) is
    r_Survey_Quiz Hdf_Survey_Quizs%rowtype;
    v_Survey_Quiz Hdf_Pref.Survey_Quiz_Rt;
    v_List_Item   Hashmap;
  begin
    for i in 1 .. i_List.Count
    loop
      v_List_Item := Treat(i_List.r_Hashmap(i) as Hashmap);
    
      r_Survey_Quiz := z_Hdf_Survey_Quizs.To_Row(v_List_Item,
                                                 z.Sv_Quiz_Id,
                                                 z.Quiz_Id,
                                                 z.Parent_Option_Id);
    
      if r_Survey_Quiz.Sv_Quiz_Id is null then
        r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      end if;
    
      Hdf_Util.Survey_Quiz_New(o_Survey_Quiz      => v_Survey_Quiz,
                               i_Sv_Quiz_Id       => r_Survey_Quiz.Sv_Quiz_Id,
                               i_Quiz_Id          => r_Survey_Quiz.Quiz_Id,
                               i_Parent_Option_Id => r_Survey_Quiz.Parent_Option_Id);
    
      Fill_Quiz_Answers(v_Survey_Quiz, v_List_Item.r_Arraylist('quiz_answers'));
    
      Hdf_Util.Survey_Quiz_Set_Add_Quiz(o_Survey_Quiz_Set => o_Survey_Quiz_Set,
                                        i_Survey_Quiz     => v_Survey_Quiz);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Survey_Quiz_Sets
  (
    o_Survey in out nocopy Hdf_Pref.Survey_Rt,
    i_List   Arraylist
  ) is
    r_Survey_Quiz_Set Hdf_Survey_Quiz_Sets%rowtype;
    v_Survey_Quiz_Set Hdf_Pref.Survey_Quiz_Set_Rt;
    v_List_Item       Hashmap;
  begin
    for i in 1 .. i_List.Count
    loop
      v_List_Item := Treat(i_List.r_Hashmap(i) as Hashmap);
    
      r_Survey_Quiz_Set := z_Hdf_Survey_Quiz_Sets.To_Row(v_List_Item,
                                                         z.Sv_Quiz_Set_Id,
                                                         z.Quiz_Set_Id,
                                                         z.Parent_Option_Id);
    
      if r_Survey_Quiz_Set.Sv_Quiz_Set_Id is null then
        r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      end if;
    
      Hdf_Util.Survey_Quiz_Set_New(o_Survey_Quiz_Set  => v_Survey_Quiz_Set,
                                   i_Sv_Quiz_Set_Id   => r_Survey_Quiz_Set.Sv_Quiz_Set_Id,
                                   i_Quiz_Set_Id      => r_Survey_Quiz_Set.Quiz_Set_Id,
                                   i_Parent_Option_Id => r_Survey_Quiz_Set.Parent_Option_Id);
    
      Fill_Survey_Quizs(v_Survey_Quiz_Set, v_List_Item.r_Arraylist('quizs'));
    
      Hdf_Util.Survey_Add_Quiz_Set(o_Survey => o_Survey, i_Survey_Quiz_Set => v_Survey_Quiz_Set);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Record
  (
    o_Survey in out nocopy Hdf_Pref.Survey_Rt,
    p        Hashmap
  ) is
    r_Survey Hdf_Surveys%rowtype;
  begin
    z_Hdf_Surveys.To_Row(r_Survey,
                         p,
                         z.Survey_Id,
                         z.Quiz_Set_Group_Id,
                         z.Survey_Number,
                         z.Survey_Date,
                         z.Status,
                         z.Note);
  
    if r_Survey.Survey_Id is null then
      r_Survey.Survey_Id := Hdf_Next.Hdf_Survey_Id;
    end if;
  
    Hdf_Util.Survey_New(o_Survey            => o_Survey,
                        i_Company_Id        => Ui.Company_Id,
                        i_Survey_Id         => r_Survey.Survey_Id,
                        i_Filial_Id         => Ui.Filial_Id,
                        i_Quiz_Set_Group_Id => r_Survey.Quiz_Set_Group_Id,
                        i_Survey_Number     => r_Survey.Survey_Number,
                        i_Survey_Date       => r_Survey.Survey_Date,
                        i_Status            => r_Survey.Status,
                        i_Note              => r_Survey.Note);
  
    Fill_Survey_Quiz_Sets(o_Survey, p.r_Arraylist('quiz_sets'));
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Quiz_Set_Id(i_Name varchar2) return varchar2 is
    v_Quiz_Set_Id number;
  begin
    select t.Quiz_Set_Id
      into v_Quiz_Set_Id
      from Hd_Quiz_Sets t
     where t.Company_Id = g_Company_Id
       and t.Name = i_Name;
  
    return v_Quiz_Set_Id;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Quiz_Id(i_Name varchar2) return varchar2 is
    v_Quiz_Id number;
  begin
    select t.Quiz_Id
      into v_Quiz_Id
      from Hd_Quizs t
     where t.Company_Id = g_Company_Id
       and t.Name = i_Name;
  
    return v_Quiz_Id;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Quiz_Option_Id
  (
    i_Quiz_Id     number,
    i_Option_Name varchar2
  ) return varchar2 is
    v_Option_Id number;
  begin
    select t.Option_Id
      into v_Option_Id
      from Hd_Quiz_Options t
     where t.Company_Id = g_Company_Id
       and t.Quiz_Id = i_Quiz_Id
       and t.Name = i_Option_Name
       and Rownum = 1;
  
    return v_Option_Id;
  
  exception
    when No_Data_Found then
      return null;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_User_Id(i_Old_User_Id number) return number is
    v_User_Id number;
  begin
    select t.New_User_Id
      into v_User_Id
      from Migr_Users t
     where t.Old_User_Id = i_Old_User_Id;
  
    return v_User_Id;
  
  exception
    when No_Data_Found then
      return Md_Pref.User_Admin(g_Company_Id);
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Old_Call_Application(i_Call_Id number) return Old_Call_Applications%rowtype is
    r_Old_Call_App Old_Call_Applications%rowtype;
  begin
    select *
      into r_Old_Call_App
      from Old_Call_Applications t
     where t.Call_Id = i_Call_Id;
  
    return r_Old_Call_App;
  
  exception
    when No_Data_Found then
      return null;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Old_Call_Event(i_Call_Id number) return Old_Call_Events%rowtype is
    r_Old_Call_Event Old_Call_Events%rowtype;
  begin
    select *
      into r_Old_Call_Event
      from Old_Call_Events t
     where t.Call_Id = i_Call_Id;
  
    return r_Old_Call_Event;
  
  exception
    when No_Data_Found then
      return null;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Function Get_Old_Call_Add(i_Call_Id number) return Old_Call_Advertisings%rowtype is
    r_Old_Call_Add Old_Call_Advertisings%rowtype;
  begin
    select *
      into r_Old_Call_Add
      from Old_Call_Advertisings t
     where t.Call_Id = i_Call_Id;
  
    return r_Old_Call_Add;
  
  exception
    when No_Data_Found then
      return null;
  end;

  ---------------------------------------------------------------------------------------------------- 
  Procedure Migr_Docuemnts is
    r_Survey             Hdf_Surveys%rowtype;
    r_Survey_Quiz_Set    Hdf_Survey_Quiz_Sets%rowtype;
    r_Survey_Quiz        Hdf_Survey_Quizs%rowtype;
    r_Survey_Quiz_Answer Hdf_Survey_Quiz_Answers%rowtype;
    r_Old_Call_App       Old_Call_Applications%rowtype;
    r_Old_Call_Event     Old_Call_Events%rowtype;
    r_Old_Call_Add       Old_Call_Advertisings%rowtype;
    v_Order_No           number;
    v_Parent_Option_Id   number;
    v_Parent_Option_Id2  number;
    v_Text_Array         Array_Varchar2;
    v_Open_New_Tab       boolean;
    --------------------------------------------------  
    Procedure Order_No is
    begin
      v_Order_No := v_Order_No + 1;
    end;
  begin
    r_Survey.Company_Id        := g_Company_Id;
    r_Survey.Quiz_Set_Group_Id := Get_Quiz_Set_Group_Id;
  
    r_Survey_Quiz_Set.Company_Id    := g_Company_Id;
    r_Survey_Quiz.Company_Id        := g_Company_Id;
    r_Survey_Quiz_Answer.Company_Id := g_Company_Id;
  
    for r in (select *
                from Old_Call_Quizs)
    loop
      Fazo_Env.Set_User_Id(Get_User_Id(r.User_Id));
      r_Survey.Survey_Id     := Hdf_Next.Hdf_Survey_Id;
      r_Survey.Filial_Id     := z_Migr_Filials.Load(r.Filial_Id).New_Filial_Id;
      r_Survey.Survey_Number := Hdf_Api.Gen_Document_Number(i_Company_Id => r_Survey.Company_Id,
                                                            i_Filial_Id  => r_Survey.Filial_Id,
                                                            i_Table      => Zt.Hdf_Surveys,
                                                            i_Column     => z.Survey_Number);
      r_Survey.Survey_Date   := Trunc(r.Call_Date);
    
      case r.State
        when 'D' then
          r_Survey.Status := Hdf_Pref.c_Ss_Draft;
        when 'F' then
          r_Survey.Status := Hdf_Pref.c_Ss_Completed;
        when 'R' then
          r_Survey.Status := Hdf_Pref.c_Ss_Removed;
        else
          null;
      end case;
    
      z_Hdf_Surveys.Insert_Row(r_Survey);
    
      v_Order_No := 1;
      --quiz_sets 
      r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      r_Survey_Quiz_Set.Survey_Id      := r_Survey.Survey_Id;
      r_Survey_Quiz_Set.Quiz_Set_Id    := Get_Quiz_Set_Id('Основной');
      z_Hdf_Survey_Quiz_Sets.Insert_Row(r_Survey_Quiz_Set);
    
      --Основной quiz set' s Quizs
      --Номер звонка
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Номер звонка');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r.Code;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Дата и время
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Дата и время');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := Trunc(r.Call_Date);
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Не Анонимно
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Не Анонимно');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
    
      if r.Is_Anonymous <> 'Y' then
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Да');
        r_Survey_Quiz_Answer.Answer    := 'Да';
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Имя звонившего
      if r.Is_Anonymous <> 'Y' then
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Имя звонившего');
        r_Survey_Quiz.Order_No         := v_Order_No;
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Caller_Name;
      
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      r_Survey_Quiz.Parent_Option_Id := '';
      --Номер звонящего
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Номер звонящего');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r.Caller_Number;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Пол
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Пол');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
    
      if r.Gender = 'M' then
        r_Survey_Quiz_Answer.Answer    := 'Мужчина';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Мужчина');
      elsif r.Gender = 'F' then
        r_Survey_Quiz_Answer.Answer    := 'Женщина';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Женщина');
      else
        r_Survey_Quiz_Answer.Option_Id := '';
        r_Survey_Quiz_Answer.Answer    := '';
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Вид консультирования
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Вид консультирования');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
    
      if r.Coubseling_View = 'F' then
        r_Survey_Quiz_Answer.Answer    := 'Первично';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Первично');
      elsif r.Coubseling_View = 'S' then
        r_Survey_Quiz_Answer.Answer    := 'Вторично';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Вторично');
      else
        r_Survey_Quiz_Answer.Option_Id := '';
        r_Survey_Quiz_Answer.Answer    := '';
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Место нахождение звонящего / Регион
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Место нахождение звонящего / Регион');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r.Location_Place;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Location_Place);
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Способ обращения
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Способ обращения');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r.Treatment_Method;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Treatment_Method);
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Возраст
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Возраст');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r.Age;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Age);
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Гражданство
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Гражданство');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Citizenship);
    
      if r_Survey_Quiz_Answer.Option_Id is null and r.Citizenship is not null then
        r_Survey_Quiz_Answer.Answer    := 'другое гражданство';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'другое гражданство');
      else
        r_Survey_Quiz_Answer.Answer := r.Citizenship;
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r_Survey_Quiz_Answer.Answer = 'другое гражданство' then
        --другой Гражданство
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другое гражданство');
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
        r_Survey_Quiz.Parent_Option_Id := null;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Citizenship;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      --Национальность
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Национальность');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Nationality);
    
      if r_Survey_Quiz_Answer.Option_Id is null and r.Nationality is not null then
        r_Survey_Quiz_Answer.Answer    := 'другая национальность';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'другая национальность');
      else
        r_Survey_Quiz_Answer.Answer := r.Nationality;
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r_Survey_Quiz_Answer.Answer = 'другая национальность' then
        --другой Национальность
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другая национальность');
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
        r_Survey_Quiz.Parent_Option_Id := null;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Nationality;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      --Дополнительно quiz_set
      v_Order_No := 1;
      --quiz_sets 
      r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      r_Survey_Quiz_Set.Survey_Id      := r_Survey.Survey_Id;
      r_Survey_Quiz_Set.Quiz_Set_Id    := Get_Quiz_Set_Id('Дополнительно');
      z_Hdf_Survey_Quiz_Sets.Insert_Row(r_Survey_Quiz_Set);
    
      --Дополнительно quiz set's quizs
      --Семейное положение
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Семейное положение');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Family_State);
      r_Survey_Quiz_Answer.Answer          := r.Family_State;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Наличие детей
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Наличие детей');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
    
      if r.Has_Child = 'Y' then
        r_Survey_Quiz_Answer.Answer    := 'Да';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Да');
      elsif r.Has_Child = 'N' then
        r_Survey_Quiz_Answer.Answer    := 'Нет';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Нет');
      else
        r_Survey_Quiz_Answer.Option_Id := '';
        r_Survey_Quiz_Answer.Answer    := '';
      end if;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Образование
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Образование');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Education);
      r_Survey_Quiz_Answer.Answer          := r.Education;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Статус работы
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Статус работы');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Work_State);
      r_Survey_Quiz_Answer.Answer          := r.Work_State;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Профессия
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Профессия');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Profession);
    
      if r_Survey_Quiz_Answer.Option_Id is null and r.Profession is not null then
        r_Survey_Quiz_Answer.Answer    := 'другая профессия';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'другая профессия');
      else
        r_Survey_Quiz_Answer.Answer := r.Profession;
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r_Survey_Quiz_Answer.Answer = 'другая профессия' then
        --другой профессия
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другая профессия');
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
        r_Survey_Quiz.Parent_Option_Id := null;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Profession;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      --Откуда узнали о горячей линии
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Откуда узнали о горячей линии');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Learned_About);
    
      if r_Survey_Quiz_Answer.Option_Id is null and r.Learned_About is not null then
        r_Survey_Quiz_Answer.Answer    := 'другие горячие линии';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'другие горячие линии');
      else
        r_Survey_Quiz_Answer.Answer := r.Learned_About;
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r_Survey_Quiz_Answer.Answer = 'другие горячие линии' then
        --другие горячие линии
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другие горячие линии');
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
        r_Survey_Quiz.Parent_Option_Id := null;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Learned_About;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      --Вопросы quiz_set
      v_Order_No := 1;
      --quiz_sets 
      r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      r_Survey_Quiz_Set.Survey_Id      := r_Survey.Survey_Id;
      r_Survey_Quiz_Set.Quiz_Set_Id    := Get_Quiz_Set_Id('Вопросы');
      z_Hdf_Survey_Quiz_Sets.Insert_Row(r_Survey_Quiz_Set);
    
      --Вопросы quiz set's quizs
      --Страна назначения
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Страна назначения');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.City_Destination);
    
      if r_Survey_Quiz_Answer.Option_Id is null and r.City_Destination is not null then
        r_Survey_Quiz_Answer.Answer    := 'другая страна назначения';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'другая страна назначения');
      else
        r_Survey_Quiz_Answer.Answer := r.City_Destination;
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r_Survey_Quiz_Answer.Answer = 'другая страна назначения' then
        --другая страна назначения
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другая страна назначения');
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
        r_Survey_Quiz.Parent_Option_Id := null;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.City_Destination;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      --Информация о юридическом или физическом лице предоставляющим услуги по вывозу за рубеж или трудоустройству
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Информация о юридическом или физическом лице предоставляющим услуги по вывозу за рубеж или трудоустройству');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Person_Info);
      r_Survey_Quiz_Answer.Answer          := r.Person_Info;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Тип вопроса звонящего или основная проблема с которой обратился звонивший
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Тип вопроса звонящего или основная проблема с которой обратился звонивший');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => r.Question_Type);
    
      if r_Survey_Quiz_Answer.Option_Id is null and r.Question_Type is not null then
        r_Survey_Quiz_Answer.Answer    := 'другой тип вопроса звонящего или основная проблема с которой обратился звонивший';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'другой тип вопроса звонящего или основная проблема с которой обратился звонивший');
      else
        r_Survey_Quiz_Answer.Answer := r.Question_Type;
      end if;
    
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r_Survey_Quiz_Answer.Answer =
         'другой тип вопроса звонящего или основная проблема с которой обратился звонивший' then
        --другой тип вопроса звонящего или основная проблема с которой обратился звонивший
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другой тип вопроса звонящего или основная проблема с которой обратился звонивший');
        r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
        r_Survey_Quiz.Parent_Option_Id := null;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Question_Type;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end if;
    
      --Описание ситуации
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Описание ситуации');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r.Situation;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Действие оператора quiz_set
      v_Order_No := 1;
      --quiz_sets 
      r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      r_Survey_Quiz_Set.Survey_Id      := r_Survey.Survey_Id;
      r_Survey_Quiz_Set.Quiz_Set_Id    := Get_Quiz_Set_Id('Действие оператора');
      z_Hdf_Survey_Quiz_Sets.Insert_Row(r_Survey_Quiz_Set);
    
      --Действие оператора quiz set's quizs
      --Действие оператора
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Действие оператора');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      v_Text_Array := Fazo.Split(r.Operator_Action, ',');
      for j in 1 .. v_Text_Array.Count
      loop
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
        r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                   i_Option_Name => v_Text_Array(j));
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end loop;
    
      --Клиент получил следующую информацию
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Клиент получил следующую информацию');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      v_Text_Array := Fazo.Split(r.Get_Info, ',');
      for j in 1 .. v_Text_Array.Count
      loop
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
        r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                   i_Option_Name => v_Text_Array(j));
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      end loop;
    
      v_Open_New_Tab := false;
      if 'Консультация юриста' member of v_Text_Array then
        v_Open_New_Tab := true;
      end if;
    
      --Было ли принято заявление на оказание помощи
      r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Quiz_Id    := Get_Quiz_Id('Было ли принято заявление на оказание помощи');
      r_Survey_Quiz.Order_No   := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
    
      if r.Has_Application = 'Y' then
        r_Survey_Quiz_Answer.Answer    := 'Да';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Да');
      elsif r.Has_Application = 'N' then
        r_Survey_Quiz_Answer.Answer    := 'Нет';
        r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                             i_Option_Name => 'Нет');
      else
        r_Survey_Quiz_Answer.Option_Id := '';
        r_Survey_Quiz_Answer.Answer    := '';
      end if;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      if r.Has_Application = 'Y' then
        v_Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
        r_Old_Call_App     := Get_Old_Call_Application(r.Call_Id);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Номер заявления');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.App_Number;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Дата заявления');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.App_Date;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Ф.И.О. Заявителя');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Application_Name;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Место проживания');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Extra_Name;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Место проживания');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Live_Place;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Паспортные данные Заявителя');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Identification_Data;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Паспортные данные ЖТЛ');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Extra_Identification;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Количество мужчин');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Count_Men;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Количество женщин');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Count_Men;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Количество детей');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Count_Men;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Статус заявления');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                   i_Option_Name => r_Old_Call_App.Application_State);
      
        if r_Survey_Quiz_Answer.Option_Id is null and r_Old_Call_App.Application_State is not null then
          r_Survey_Quiz_Answer.Answer    := 'другая статус заявления';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'другая статус заявления');
        else
          r_Survey_Quiz_Answer.Answer := r_Old_Call_App.Application_State;
        end if;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id   := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Характер заявления');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        v_Text_Array := Fazo.Split(r_Old_Call_App.Application_Type, ',');
        for j in 1 .. v_Text_Array.Count
        loop
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
          r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                     i_Option_Name => v_Text_Array(j));
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end loop;
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id   := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Описание оказанной помощи');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        v_Text_Array := Fazo.Split(r_Old_Call_App.Help, ',');
        for j in 1 .. v_Text_Array.Count
        loop
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
          r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                     i_Option_Name => v_Text_Array(j));
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end loop;
      
        --Конечный результат
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Конечный результат');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      
        v_Text_Array := Fazo.Split(r_Old_Call_App.Result, ',');
        for j in 1 .. v_Text_Array.Count
        loop
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
          r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                     i_Option_Name => v_Text_Array(j));
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end loop;
      
        if 'Вернулись' member of v_Text_Array then
          r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
          r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Дата возвращения');
          r_Survey_Quiz.Order_No         := v_Order_No;
          r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
          z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
          Order_No;
        
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Return_Date;
        
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end if;
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Статус кейса');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      
        if r_Old_Call_App.Case_State = 'O' then
          r_Survey_Quiz_Answer.Answer    := 'Открыт';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Открыт');
        elsif r_Old_Call_App.Case_State = 'C' then
          r_Survey_Quiz_Answer.Answer    := 'Женщина';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Закрыт');
        else
          r_Survey_Quiz_Answer.Option_Id := '';
          r_Survey_Quiz_Answer.Answer    := '';
        end if;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Партнеры в возвращении');
        r_Survey_Quiz.Order_No         := v_Order_No;
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                   i_Option_Name => r_Old_Call_App.Partner_Return);
      
        if r_Survey_Quiz_Answer.Option_Id is null and r_Old_Call_App.Partner_Return is not null then
          r_Survey_Quiz_Answer.Answer    := 'другой партнеры в возвращении';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'другой партнеры в возвращении');
        else
          r_Survey_Quiz_Answer.Answer := r_Old_Call_App.Partner_Return;
        end if;
      
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        if r_Survey_Quiz_Answer.Answer = 'другой партнеры в возвращении' then
          --другой партнеры в возвращении
          r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
          r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('другой партнеры в возвращении');
          r_Survey_Quiz.Parent_Option_Id := r_Survey_Quiz_Answer.Option_Id;
          r_Survey_Quiz.Order_No         := v_Order_No;
          z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
          Order_No;
        
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := r_Old_Call_App.Partner_Return;
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end if;
      
        r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Было перенаправление в ПО');
        r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id;
        r_Survey_Quiz.Order_No         := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      
        if r_Old_Call_App.Has_Matter = 'Y' then
          r_Survey_Quiz_Answer.Answer    := 'Да';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Да');
        elsif r_Old_Call_App.Case_State = 'N' then
          r_Survey_Quiz_Answer.Answer    := 'Нет';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Нет');
        else
          r_Survey_Quiz_Answer.Option_Id := '';
          r_Survey_Quiz_Answer.Answer    := '';
        end if;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        if r_Old_Call_App.Has_Matter = 'Y' then
          v_Parent_Option_Id2 := r_Survey_Quiz_Answer.Option_Id;
        
          r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
          r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Статус дела');
          r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id2;
          r_Survey_Quiz.Order_No         := v_Order_No;
          z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
          Order_No;
        
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          if r_Old_Call_App.Has_Matter = 'O' then
            r_Survey_Quiz_Answer.Answer    := 'Открыт';
            r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => 'Открыт');
          elsif r_Old_Call_App.Case_State = 'C' then
            r_Survey_Quiz_Answer.Answer    := 'Закрыт';
            r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                 i_Option_Name => 'Закрыт');
          else
            r_Survey_Quiz_Answer.Option_Id := '';
            r_Survey_Quiz_Answer.Answer    := '';
          end if;
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        
          r_Survey_Quiz.Sv_Quiz_Id       := Hdf_Next.Hdf_Sv_Quiz_Id;
          r_Survey_Quiz.Quiz_Id          := Get_Quiz_Id('Описания дела');
          r_Survey_Quiz.Parent_Option_Id := v_Parent_Option_Id2;
          r_Survey_Quiz.Order_No         := v_Order_No;
          z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
          Order_No;
        end if;
      end if;
    
      --Мероприятие
      v_Order_No                       := 1;
      r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      r_Survey_Quiz_Set.Survey_Id      := r_Survey.Survey_Id;
      r_Survey_Quiz_Set.Quiz_Set_Id    := Get_Quiz_Set_Id('Мероприятие');
      z_Hdf_Survey_Quiz_Sets.Insert_Row(r_Survey_Quiz_Set);
    
      r_Old_Call_Event := Get_Old_Call_Event(r.Call_Id);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Проведенные мероприятия Дата');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Event.Event_Date;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Проведенные мероприятия Место');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Event.Event_Place;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Проведенные мероприятия Цель');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Event.Event_Gol;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Old_Call_Event := Get_Old_Call_Event(r.Call_Id);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Рекламная компания Дата');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Add.Advertising_Date;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Рекламная компания Издание');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Add.Edition_Name;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Рекламная компания Издание Количество');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Add.Edition_Count;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Рекламная компания Радиостанция');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Add.Station_Name;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Рекламная компания Радиостанция Количество');
      r_Survey_Quiz.Order_No       := v_Order_No;
      z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
      Order_No;
    
      r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz_Answer.Answer          := r_Old_Call_Add.Station_Count;
      z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
    
      --Консультация юриста
      if v_Open_New_Tab then
        v_Order_No                       := 1;
        r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
        r_Survey_Quiz_Set.Survey_Id      := r_Survey.Survey_Id;
        r_Survey_Quiz_Set.Quiz_Set_Id    := Get_Quiz_Set_Id('Консультация юриста');
        z_Hdf_Survey_Quiz_Sets.Insert_Row(r_Survey_Quiz_Set);
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Виды оказания юридической помощи');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Cinfo_Help;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Рядом результаты');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
        r_Survey_Quiz_Answer.Answer          := r.Cinfo_Res;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Перенаправление в ПО');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      
        if r.Cinfo_To = 'Y' then
          r_Survey_Quiz_Answer.Answer    := 'Да';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Да');
        elsif r.Cinfo_To = 'N' then
          r_Survey_Quiz_Answer.Answer    := 'Нет';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Нет');
        else
          r_Survey_Quiz_Answer.Answer    := '';
          r_Survey_Quiz_Answer.Option_Id := '';
        end if;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Пернаправление из ПО');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      
        if r.Cinfo_From = 'Y' then
          r_Survey_Quiz_Answer.Answer    := 'Да';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Да');
        elsif r.Cinfo_From = 'N' then
          r_Survey_Quiz_Answer.Answer    := 'Нет';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Нет');
        else
          r_Survey_Quiz_Answer.Answer    := '';
          r_Survey_Quiz_Answer.Option_Id := '';
        end if;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Тип консультации');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        v_Text_Array := Fazo.Split(r.Cinfo_Type, ',');
        for j in 1 .. v_Text_Array.Count
        loop
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
          r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                     i_Option_Name => v_Text_Array(j));
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end loop;
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Виды эксплуатации');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        v_Text_Array := Fazo.Split(r.Cinfo_Kind, ',');
        for j in 1 .. v_Text_Array.Count
        loop
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := v_Text_Array(j);
          r_Survey_Quiz_Answer.Option_Id       := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                                     i_Option_Name => v_Text_Array(j));
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end loop;
      
        r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
        r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
        r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('Открытие УД');
        r_Survey_Quiz.Order_No       := v_Order_No;
        z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
        Order_No;
      
        r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
        r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
      
        if r.Cinfo_Open = 'Y' then
          r_Survey_Quiz_Answer.Answer    := 'Да';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Да');
        elsif r.Cinfo_Open = 'N' then
          r_Survey_Quiz_Answer.Answer    := 'Нет';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'Нет');
        elsif r.Cinfo_Open = 'C' then
          r_Survey_Quiz_Answer.Answer    := 'отказ';
          r_Survey_Quiz_Answer.Option_Id := Get_Quiz_Option_Id(i_Quiz_Id     => r_Survey_Quiz.Quiz_Id,
                                                               i_Option_Name => 'отказ');
        else
          r_Survey_Quiz_Answer.Answer    := '';
          r_Survey_Quiz_Answer.Option_Id := '';
        end if;
        z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
      
        if r.Cinfo_Open = 'C' then
          r_Survey_Quiz.Sv_Quiz_Id     := Hdf_Next.Hdf_Sv_Quiz_Id;
          r_Survey_Quiz.Sv_Quiz_Set_Id := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
          r_Survey_Quiz.Quiz_Id        := Get_Quiz_Id('отказ причина');
          r_Survey_Quiz.Order_No       := v_Order_No;
          z_Hdf_Survey_Quizs.Insert_Row(r_Survey_Quiz);
          Order_No;
        
          r_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
          r_Survey_Quiz_Answer.Sv_Quiz_Id      := r_Survey_Quiz.Sv_Quiz_Id;
          r_Survey_Quiz_Answer.Answer          := r.Cinfo_Open_Note;
          z_Hdf_Survey_Quiz_Answers.Insert_Row(r_Survey_Quiz_Answer);
        end if;
      end if;
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Migration_Execute(i_Company_Id number) is
  begin
    g_Company_Id := i_Company_Id;
    Biruni_Route.Context_Begin;
    Ui_Auth.Logon_As_System(g_Company_Id);
  
    Migr_Filials;
    Migr_Quiz_Set_Group;
    Migr_Quiz_Sets;
    Migr_Quiz_Set_Group_Binds;
    Migr_Quizs;
  
    Migr_Docuemnts;
    Biruni_Route.Context_End;
  end;

end Migr_Helpdesk;
/
