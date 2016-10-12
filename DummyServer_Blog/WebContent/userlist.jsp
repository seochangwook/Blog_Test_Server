<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%@page import="DB.*"%>
<%@page import="java.util.*"%>

<%
//Charcterset//
request.setCharacterEncoding("UTF-8");
%>
<%
//필요한 변수를 할당//
String receive_department_name;

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

boolean is_save = false; //처음은 실패라 가정//
log log_file = new log();

//이미지값 경로//
String uploadPath = "http://"+request.getLocalAddr()+":"+request.getLocalPort()+"/"+"DummyServer_Blog/images/";
%>
<%
//검색할 부서명을 얻어온다.//
receive_department_name = getParameter(request, "departmentname", "");
%>
<%
//입력받은 값으로 결과를 반환//
//데이터베이스 연결객체를 가져온다.//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSetMetaData rsmt = null;

try
{
	String query = "select * from human where human_department = ?";
	pstmt = con.prepareStatement(query);
	
	pstmt.setString(1, receive_department_name); //?가 있는 곳에 조건을 넣어준다.//
	rs = pstmt.executeQuery();
	
	//last(), beforeFirst()를 이용하여 현재 커서의 위치를 조절해주어야 한다.//
	rs.last();
	int row_count = rs.getRow();
	rs.beforeFirst(); //다시 처음으로 돌려야지 정상적인 탐색 가능//

	System.out.println("row count: "+row_count);
	
	//json배열객체를 선언. result객체의 속성에 개수추가(개수를 가지고 판단)//
	//우선 전체적으로 결과를 가질 result객체를 생성//
	//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
	JSONObject result_object = new JSONObject();

	result_object.put("count", ""+row_count); //문자열로 검색 성공과 실패를 판단. 성공 시 내부 result객체에 정보가 있다는 의미//

	//전체를 담아줄 객체 생성//
	JSONObject humanobject = new JSONObject();
	//배열을 저장할 배열객체를 생성//
	JSONArray humanlist = new JSONArray();
	
	int count = 0; //행의 개수를 셀 카운터 변수//
	//배열에 들어갈 객체를 생성//
	while(rs.next())
	{
		JSONObject humandata = new JSONObject();
		
		humandata.put("human_id", rs.getString("human_id"));
		humandata.put("human_imageurl", uploadPath+rs.getString("human_imageurl"));
		humandata.put("human_name", rs.getString("human_name"));
		humandata.put("human_age", rs.getString("human_age"));
		humandata.put("human_tel", rs.getString("human_tel"));
		humandata.put("human_job", rs.getString("human_job"));
		humandata.put("human_department", rs.getString("human_department"));
		humandata.put("human_address", rs.getString("human_address"));
		humandata.put("human_emailaddress", rs.getString("human_emailaddress"));
		humandata.put("human_introduction", rs.getString("human_introduction"));
		humandata.put("human_etcinfo", rs.getString("human_etcinfo"));
		
		//생셩된 객체를 배열객체에 저장//
		humanlist.add(count, humandata);
		
		count++;
	}
	
	humanobject.put("humanList", humanlist);
	result_object.put("results", humanobject);
	
	out.clear(); //보내기전 기존 출력내용을 초기화//
	out.println(result_object); //데이터 출력 및 전송//
	out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
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
<%!
public String getParameter(HttpServletRequest request, String parameter_name, String default_value)
{
	String receive_value = request.getParameter(parameter_name);
	
	if(receive_value == null || receive_value.equals(""))
	{
		receive_value = default_value;
	}
	
	return receive_value;
}
%>