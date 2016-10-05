<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%
request.setCharacterEncoding("UTF-8");
%>
<%
//관련 변수 선언//
String receive_name;

//인사관련 정보//
String department_name = "";
String introduction = "";
String etc = "";
String people_image = "";
%>
<%
//관련 객체 선언//
boolean is_save = false;
log log_file = new log();
%>
<%
//데이터를 받는다.//
receive_name = getParameter(request, "name", "user");
%>
<%
//데이터베이스를 활용하여서 현재 사람이 존재하는지 유무와, 존재한다면 해당 사람의 정보를 출력(디비연동은 JDBC를 사용.추후 연동)//
department_name = "Development Department";
introduction = "my introduction";
etc = "my etc";
people_image = "https://avatars2.githubusercontent.com/u/19370862?v=3&s=40";
%>
<%
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();
JSONObject user_object = new JSONObject();

user_object.put("name", receive_name);
user_object.put("department", department_name);
user_object.put("image", people_image);
user_object.put("introduction", introduction);
user_object.put("etc", etc);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call ["+receive_name+"] info";

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
//함수선언(POST전달)//
public String getParameter(HttpServletRequest request, String parameter_name, String default_value)
{
	String return_str;
	
	return_str = request.getParameter(parameter_name);
	
	if(return_str == null)
	{
		return_str = default_value;
	}
	
	else if(return_str != null)
	{
		
	}
	
	return return_str;
}
%>