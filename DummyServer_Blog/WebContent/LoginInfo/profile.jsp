<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@page import="org.json.simple.JSONArray"%>
<%@page import="java.util.*"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.*"%>
<%@page import="Log.log" %>
<%@page import="DB.*" %>

<%
//인코딩 정의//
request.setCharacterEncoding("UTF-8");
%>
<%
//필요변수 선언//
String user_id;

String get_user_id = "";
String get_user_name = "";
String get_user_emailaddress = "";
String get_user_gender = "";
String get_user_profileimageurl = "";
String get_user_auth_login = "";

boolean is_save = false; //처음은 실패라 가정//
boolean is_success = false; //프로필 정보가 없다고 가정//
//관련 클래스//
log log_file = new log();
%>
<%
//값을 받아온다.//
user_id = getParameter(request, "user_id", "");
%>
<%
//데이터베이스 작업을 한다.//
//데이터베이스 연결객체를 가져온다.//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;
ResultSet rs = null;

try
{
	String query = "select user_id, user_name, user_email, user_gender, user_imageurl, auth_login from user where user_id = ?";
	
	pstmt = con.prepareStatement(query);
	
	pstmt.setString(1, user_id);
	
	rs = pstmt.executeQuery();
	
	while(rs.next())
	{
		String search_user_id = rs.getString("user_id");
		
		//비교//
		if(search_user_id.equals(user_id))
		{
			//일치하는 정보가 있으니 해당 정보를 저장(데이터 전달)//
			get_user_id = rs.getString("user_id");
			get_user_name = rs.getString("user_name");
			get_user_emailaddress = rs.getString("user_email");
			get_user_gender = rs.getString("user_gender");
			get_user_profileimageurl = rs.getString("user_imageurl");
			get_user_auth_login = rs.getString("auth_login");
			
			is_success = true;
			
			break;
		}
	}
}

catch(SQLException e)
{
	e.printStackTrace();
}

finally
{
	pstmt.close();
	con.close();
}
%>
<%
//결과를 json으로 생성//
//파싱된 결과를 json으로 전달//
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

result_object.put("is_success", ""+is_success); //문자열로 검색 성공과 실패를 판단. 성공 시 내부 result객체에 정보가 있다는 의미//
//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject user_object = new JSONObject();

user_object.put("user_id", get_user_id);
user_object.put("user_profileimageurl", get_user_profileimageurl);
user_object.put("user_name", get_user_name);
user_object.put("user_email", get_user_emailaddress);
user_object.put("user_gender", get_user_gender);
user_object.put("auth_login", get_user_auth_login);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call [profile call]";

is_save = log_file.SaveLogInfo(log_data, 0);
is_save = log_file.SaveLogInfo("---------------------------------", 1);

if(is_save == false)
{
	System.out.println("Save Log ERROR");
}

else if(is_save == true)
{
	System.out.println("Save Log SUCCESS");
}
%>
<%!
//함수선언(method: POST)//
public String getParameter(HttpServletRequest request, String parameter_name, String default_value)
{
	String return_str;
	
	return_str = request.getParameter(parameter_name);
	
	if(return_str == null || return_str.equals(""))
	{
		return_str = default_value;
	}
	
	else if(return_str != null)
	{
		
	}
	
	return return_str;
}
%>