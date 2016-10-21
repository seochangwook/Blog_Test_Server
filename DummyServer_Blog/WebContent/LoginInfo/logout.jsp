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
//필요한 변수 설정//
String user_id; //조건으로 사용될 값//
String auth_login = "0"; //로그아웃 상태로 바꾸어야 하므로 0으로 업데이트//

boolean is_save = false; //처음은 실패라 가정//
boolean is_success = true; //로그아웃 성공이라 가정//
//관련 클래스//
log log_file = new log();
%>
<%
//값을 받아온다.//
user_id = getParameter(request, "user_id", "");
%>
<%
//로그아웃 이므로 테이블에 로그인 유효변수를 로그아웃 상태로 변경해준다.//
boolean is_logout = logout(user_id,auth_login);

if(is_logout == false)
{
	is_success = false;
}
%>
<%
//로그아웃 완료인 메시지를 보낸다.//
//응답 json메시지 설정//
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject logout_object = new JSONObject();

logout_object.put("is_success", is_success);

result_object.put("result", logout_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%!
public boolean logout(String user_id, String auth_login)
{
	boolean is_check = true;
	
	//연결객체 생성//
	Connection con = DBConnection.makeConnection();
					
	//PrepareStatement 설정//
	PreparedStatement pstmt = null;
	
	try
	{	
		String query = "UPDATE user SET auth_login = ? WHERE user_id = ?";
		
		pstmt = con.prepareStatement(query);
		
		pstmt.setString(1, auth_login);
		pstmt.setString(2, user_id);
		
		//쿼리 적용//
		int result_code = pstmt.executeUpdate();
		
		if(result_code == 0)
		{
			is_check = false;
		}
		
		return is_check;
	}
	
	catch(SQLException e)
	{
		e.printStackTrace();
		
	}
	
	return is_check;
}
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call [logout]";

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