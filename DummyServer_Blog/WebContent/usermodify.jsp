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
//정보에 대한 수정은 이미지, 이름, 부서명, 전화번호, 주소로 한정()//
String receive_id = "";
String original_id = "";
String original_imageurl = ""; //이미지는 기존 지정안될 수 도 있기에 설정//

String new_imageurl = "";
String new_name = "";
String new_departmentname = "";
String new_tel = "";
String new_address = "";

boolean is_update = false; //수정실패라 가정//
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
//수정된 값들을 받아온다.//
MultipartRequest multirequest = new MultipartRequest(request, uploadPath, size, "utf-8", new DefaultFileRenamePolicy());

receive_id = getMultiParameter(multirequest, "id", ""); //변경할 사람의 정보에 대한 id값//

new_name = getMultiParameter(multirequest, "name", "");
new_departmentname = getMultiParameter(multirequest, "departmentname", "");
new_tel = getMultiParameter(multirequest, "tel", "");
new_address = getMultiParameter(multirequest, "address", "");

//기존 저장되어있던 값을 불러온다.(변경할려는 이름값을 가지고 찾는다.)//
original_imageurl = get_imageurl(receive_id);

System.out.println("original imageurl: "+original_imageurl);

try
{
	Enumeration files = multirequest.getFileNames();
	//업로드한 파일들의 이름을 얻어옴//
	String file = (String)files.nextElement();
	//파일이 중복되면 자동 renameming진행 ex) ~_1.png//
	//중복일 경우 해당 rename결과를 그대로 사용하고 새로운거면 새로운 걸로 저장//
	new_imageurl = multirequest.getFilesystemName(file);
}

catch(Exception e) //클라이언트에서 이미지에 대한 수정이 없을 경우 해당 예외가 발생//
{
	new_imageurl = "";
	
	//사용자가 이미지를 변경하지 않을경우 기존 이미지가 반영//
	new_imageurl = original_imageurl; 
	
	System.out.println("image:"+new_imageurl);
}
%>
<%
//수정된 정보를 저장//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;

try
{
	String query = "UPDATE human SET human_name=?, human_imageurl=?, human_tel=?, human_address=?, human_department=? WHERE human_id=?";
	pstmt = con.prepareStatement(query);
	
	pstmt.setString(1, new_name);
	pstmt.setString(2, new_imageurl);
	pstmt.setString(3, new_tel);
	pstmt.setString(4, new_address);
	pstmt.setString(5, new_departmentname);
	pstmt.setString(6, receive_id);
	
	int result_code = pstmt.executeUpdate();
	
	if(result_code == 0)
	{
		is_update = false;
	}
	
	else if(result_code == 1)
	{
		is_update = true;
	}
	
	System.out.println("modify success...");
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

user_object.put("is_save", is_update);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call ["+new_name+"] member modify";

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
public String get_imageurl(String search_id)
{
	//쿼리를 두번 실행하는 것보다 한번에 값을 다 가져오고 그 값들을 배열로 반환//
	String get_imageurl = "";
	
	//입력받은 값으로 결과를 반환//
	//데이터베이스 연결객체를 가져온다.//
	Connection con = DBConnection.makeConnection();

	//PrepareStatement 설정//
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	try
	{
		String query = "select human_imageurl from human where human_id = ?";
		pstmt = con.prepareStatement(query);
		
		pstmt.setString(1, search_id); //?가 있는 곳에 조건을 넣어준다.//
		rs = pstmt.executeQuery();
		
		while(rs.next())
		{
			get_imageurl = rs.getString("human_imageurl");
		}
		
		//자원을 해제한다.//
		pstmt.close();
		rs.close();
		con.close();
		
		return get_imageurl;
	}
	
	catch (SQLException e) 
	{
	    e.printStackTrace();
	}
	
	return get_imageurl;
}
%>