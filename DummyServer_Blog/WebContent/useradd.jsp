<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%@page import="DB.*"%>
<%@page import="com.oreilly.servlet.multipart.*"%> //파일전송을 위한 라이브러리 적용//
<%@page import="com.oreilly.servlet.*"%> //파일전송을 위한 라이브러리 적용//
<%@page import="java.util.*"%>

<%
//Charcterset//
request.setCharacterEncoding("UTF-8");
%>
<%
//variable//
String name;
String imagefilename;
String etc;
String department_name;
String introduction;

boolean is_enroll = true; //등록성공이라 가정//
//우선 저장할려는 사람이 이미 등록되어 있는지 검사//
boolean is_enroll_already; //기본적으로 가입이 안되었다는 가정//

boolean is_save = false; //처음은 실패라 가정//
log log_file = new log();
%>
<%
//image save path(다시 클라이언트로 전송 시 해당 경로값을 적용)//
String uploadPath = "/Users/apple/git/BlogtestServer/DummyServer_Blog/WebContent/images";
//image max size(exception)//
int size = 10*1024*1024;
%>
<%
//전달된 값을 받아온다.//
//MultipartRequest 적용(파일이나 대용량 데이터 보낼때 데이터 전송방식)//
//해당 서버로 데이터 전송 시 POST타입 : form-data//
//어렵게 MultipartRequest를 구현없이 cos.jar에 MultipartRequest를 사용//
MultipartRequest multirequest = new MultipartRequest(request, uploadPath, size, "utf-8", new DefaultFileRenamePolicy());

name = getMultiParameter(multirequest, "name", "user");
etc = getMultiParameter(multirequest, "etc", "");
department_name = getMultiParameter(multirequest, "departmentname", "no department");
introduction = getMultiParameter(multirequest, "introduction", "");

//업로드한 파일들을 Enumeration타입으로 반환//
//Enumeration형은 데이터를 뽑아올때 유용한 인터페이스//
Enumeration files = multirequest.getFileNames();
//업로드한 파일들의 이름을 얻어옴//
String file = (String)files.nextElement();
//파일이 중복되면 자동 renameming진행 ex) ~_1.png//
imagefilename = multirequest.getFilesystemName(file);

System.out.println("name: "+name);
System.out.println("department: "+department_name);
System.out.println("introduction: "+introduction);
System.out.println("etc: "+etc);
System.out.println("upload file: "+imagefilename);
//이미지에 대한 저장은 파일이름이 저장되고, 출력 시 경로를 붙여준다.(길이문제 고려)//
%>
<%
//정보저장 작업(데이터베이스)//
//데이터베이스 연결객체를 가져온다.//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;

try
{
	//저장을 하기 전 중복가입여부를 판단(동명이인을 판단하기 위한 개발부서까지 조건에 추가)//
	is_enroll_already = CheckEnrollDuplicate(name, department_name);
	
	if(is_enroll_already == false)
	{
		String query = "INSERT INTO human(name, departmentname, imageurl, introduction, etc) VALUES(?,?,?,?,?)";
		pstmt = con.prepareStatement(query);
	
		//값 셋팅//
		pstmt.setString(1,name);
		pstmt.setString(2,department_name);
		pstmt.setString(3,imagefilename);
		pstmt.setString(4,introduction);
		pstmt.setString(5,etc);
	
		int result_code = pstmt.executeUpdate();
	
		if(result_code == 0)
		{
			is_enroll = false;
		}
	}
	
	else if(is_enroll_already == true)
	{
		is_enroll = false; //저장실패의 경우로 판단//
	}
}

catch(Exception e)
{
	e.getMessage();
}
%>
<%
//응답 json메시지 설정//
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject user_object = new JSONObject();

user_object.put("is_save", is_enroll);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call ["+name+"] member add";

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
public String getMultiParameter(MultipartRequest multirequest, String parameter_name, String default_value)
{
	String parameter_value = "";
	
	parameter_value = multirequest.getParameter(parameter_name);
	
	if(parameter_value == null || parameter_value.equals(""))
	{
		parameter_value = default_value;
	}
	
	return parameter_value;
}
%>
<%!
public boolean CheckEnrollDuplicate(String name, String department_name)
{
	boolean is_check = false; //가입이 안되었다는 가정//
	
	//데이터베이스에서 검색작업 실시//
	//데이터베이스 연결객체를 가져온다.//
	Connection con = DBConnection.makeConnection();

	//PrepareStatement 설정//
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	ResultSetMetaData rsmt = null;
	
	try
	{
		String query = "select name, departmentname from human";
		pstmt = con.prepareStatement(query);
		
		rs = pstmt.executeQuery(); //쿼리문을 수행//
		
		while(rs.next())
		{
			//존재하는지 비교//
			String search_name = rs.getString("name");
			String search_departmentname = rs.getString("departmentname");
			
			if(search_name.equals(name) && search_departmentname.equals(department_name))
			{
				//해당 정보가 이미 존재//
				is_check = true;
				
				break; //더 이상 검색필요없으니 종료.//
			}
		}
		
		return is_check;
	}
	
	catch(SQLException e)
	{
		e.getMessage();
	}
	
	finally
	{
		//자원을 해제한다.//
		try
		{
			pstmt.close();
			rs.close();
			con.close();
		}
		
		catch(SQLException e)
		{
			e.getMessage();
		}
	}
	
	return is_check;
}
%>