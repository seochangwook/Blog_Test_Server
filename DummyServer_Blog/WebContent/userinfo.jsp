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
String department_name = "";
String introduction = "";
String etc = "";
String people_image = "";

//데이터베이스 성공유무 확인변수//
boolean is_success = false;
String error_msg = "";
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
	String query = "select name, departmentname, imageurl, introduction, etc from human where name = ?";
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
	if(row_count >= 1)
	{
		//만약 결과가 여러개이라면 JSONArray를 이용해서 작업을 한다.//
		while(rs.next()) //디비를 검색//
		{
			receive_name = rs.getString("name");
			department_name = rs.getString("departmentname");
			people_image = rs.getString("imageurl");
			introduction = rs.getString("introduction");
			etc = rs.getString("etc");
		}
		
		is_success = true;
	}
	
	else if(row_count == 0) //아무것도 검색되지 않은 경우//
	{
		error_msg = "no human";
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

//검색조건에 따른 각각의 json데이터를 만들어 준다.//
if(is_success == true)
{
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
}

else if(is_success == false)
{
	result_object.put("error", error_msg);
	
	out.clear(); //보내기전 기존 출력내용을 초기화//
	out.println(result_object); //데이터 출력 및 전송//
	out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
}
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