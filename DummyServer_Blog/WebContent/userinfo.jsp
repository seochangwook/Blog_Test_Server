<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%@page import="DB.*"%>
<%
request.setCharacterEncoding("UTF-8");

System.out.println("* Local name: "+request.getLocalName());
System.out.println("* Local port: "+request.getLocalPort());
System.out.println("* Local addr: "+request.getLocalAddr());
System.out.println("* Remote host: "+request.getRemoteHost());
System.out.println("* Remote addr: "+request.getRemoteAddr());
System.out.println("* Remote port: "+request.getRemotePort());

%>
<%
//관련 변수 선언//
String receive_name;

//인사관련 정보//
String human_id = "";
String human_name = "";
String human_imageurl = "";
String human_age = "";
String human_tel = "";
String human_job = "";
String human_department = "";
String human_address = "";
String human_emailaddress = "";
String human_introduction = "";
String human_etcinfo = "";

//데이터베이스 성공유무 확인변수//
boolean is_success = false;
String error_msg = "";

//이미지값 경로//
String uploadPath = "http://"+request.getLocalAddr()+":"+request.getLocalPort()+"/"+"DummyServer_Blog/images/";
%>
<%
//관련 객체 선언//
boolean is_save = false; //처음은 실패라 가정//
log log_file = new log();
%>
<%
//데이터를 받는다.//
receive_name = getParameter(request, "name", "user");
%>
<%
//데이터베이스 연결객체를 가져온다.//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSetMetaData rsmt = null;

try
{		
	String query = "select * from human where human_name = ?";
	pstmt = con.prepareStatement(query);
	
	System.out.println("search name: "+receive_name);
	
	pstmt.setString(1, receive_name); //?가 있는 곳에 조건을 넣어준다.//
	rs = pstmt.executeQuery();
	
	//last(), beforeFirst()를 이용하여 현재 커서의 위치를 조절해주어야 한다.//
	rs.last();
	int row_count = rs.getRow();
	rs.beforeFirst(); //다시 처음으로 돌려야지 정상적인 탐색 가능//

	System.out.println("row count: "+row_count);
	
	//현재 이름이 존재하는지 검사. 행의 개수가 0개이면 검색이 되지 않은 것.//
	//동명이인도 고려하면 더 세부적인 조건이 필요하지만 생략//
	if(row_count >= 1)
	{
		//만약 결과가 여러개이라면 JSONArray를 이용해서 작업을 한다.//
		while(rs.next()) //디비를 검색//
		{
			human_id = rs.getString("human_id");
			human_name = rs.getString("human_name");
			human_imageurl = rs.getString("human_imageurl");
			human_age = rs.getString("human_age");
			human_tel = rs.getString("human_tel");
			human_job = rs.getString("human_job");
			human_department = rs.getString("human_department");
			human_address = rs.getString("human_address");
			human_emailaddress = rs.getString("human_emailaddress");
			human_introduction = rs.getString("human_introduction");
			human_etcinfo = rs.getString("human_etcinfo");
		}
		
		is_success = true; //성공했으니 true//
	}
}

catch (SQLException e) 
{
    e.printStackTrace();
}

finally
{
	//자원을 해제한다.//
	pstmt.close();
	rs.close();
	con.close();
}
%>
<%
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

result_object.put("is_success", ""+is_success); //문자열로 검색 성공과 실패를 판단. 성공 시 내부 result객체에 정보가 있다는 의미//
//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject user_object = new JSONObject();

user_object.put("human_id", human_id);
user_object.put("human_imageurl", uploadPath+human_imageurl);
user_object.put("human_age", human_age);
user_object.put("human_name", human_name);
user_object.put("human_tel", human_tel);
user_object.put("human_job", human_job);
user_object.put("human_department", human_department);
user_object.put("human_address", human_address);
user_object.put("human_emailaddress", human_emailaddress);
user_object.put("human_introduction", human_introduction);
user_object.put("human_etcinfo", human_etcinfo);

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