<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%@page import="DB.*"%>

<%
request.setCharacterEncoding("UTF-8");
%>
<%
//관련변수 선언//
String receive_id = "";

//데이터베이스 성공유무 확인변수//
boolean is_success = false;
String error_msg = "";
//관련 객체 선언//
boolean is_save = false; //처음은 실패라 가정//
log log_file = new log();
%>
<%
//값을 받아온다.//
receive_id = getParameter(request, "id", "");
%>
<%
//제거를 하는 데이터베이스 작업//
//정보저장 작업(데이터베이스)//
//데이터베이스 연결객체를 가져온다.//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;

try
{
	String query = "DELETE FROM human WHERE human_id = ?";
	pstmt = con.prepareStatement(query);
	
	pstmt.setString(1, receive_id);
	
	int result_code = pstmt.executeUpdate();
	
	if(result_code == 0)
	{
		is_success = false;
	}
	
	else if(result_code == 1)
	{
		is_success = true;
	}
}

catch(Exception e)
{
	e.getMessage();
}
%>
<%
//json 출력작업//
//응답 json메시지 설정//
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject user_object = new JSONObject();

user_object.put("is_save", is_success);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call ["+receive_id+"] member delete";

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