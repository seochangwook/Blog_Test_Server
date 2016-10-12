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