<%@page import="beans.ItemFileDto"%>
<%@page import="beans.ItemFileDao"%>
<%@page import="beans.ItemPagination"%>
<%@page import="beans.UsersDto"%>
<%@page import="java.util.ArrayList"%>
<%@page import="beans.ItemDto"%>
<%@page import="java.util.List"%>
<%@page import="beans.ItemDao"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>노가리투어 - 관광지 목록</TITLE>
<jsp:include page="/resource/template/header_head.jsp"></jsp:include>
</HEAD>
<BODY>
<jsp:include page="/resource/template/header_body.jsp"></jsp:include>
<SECTION>
<!-- 페이지 내용 시작 -->

<%-- 관리자만 글쓰기위한 세션 받기 --%>
<%
	String usersId = (String)request.getSession().getAttribute("usersId");
	

// 	list.jsp에서 확인 후 필요없으면 삭제(회원 번호)
	int usersIdx;
	try{
		
		usersIdx = (int)request.getSession().getAttribute("usersIdx");
		
	}catch(Exception e){
		e.printStackTrace();
		usersIdx = 0;
	}
	
	
	String usersGrade = (String)request.getSession().getAttribute("usersGrade");
	//세션 Grade값이 관리자라면
	boolean admin = usersGrade != null && usersGrade.equals("관리자");
	//root path
	String root = request.getContextPath();
%>

<%-- 페이지네이션(모듈화) --%>
<%
	ItemPagination itemPagination = new ItemPagination(request);
	itemPagination.calculateList();
%>

<%-- 페이지네이션 확인을 위한 toString --%>
<%-- <%=itemPagination.toString() %> --%>

<%-- 관리자 확인을 위한 세션 찍기 --%>
<%-- <h5>(usersId = <%=usersId %>, usersIdx = <%=usersIdx %>, grade=<%=usersGrade %>)</h5> --%>

<%-- 검색 및 목록 처리 --%>
<%
	ItemDto itemDto = new ItemDto();
	List<ItemDto> list;
	ItemDao itemDao = new ItemDao();
	if(itemPagination.isSearch()){
		list = itemDao.searchList
		(itemPagination.getColumn(), itemPagination.getKeyword(), itemPagination.getBegin(), itemPagination.getEnd());
	}
	else{
		list = itemDao.list
		(itemPagination.getBegin(), itemPagination.getEnd());
	}
	String title = itemPagination.isSearch() ? "["+itemPagination.getKeyword()+"]" + " 검색" : "관광지 목록";
%>

<%-- 썸네일표시를 위한 파일 조회를 위한 ItemFileDao 생성 --%>
<%
 	ItemFileDao itemFileDao = new ItemFileDao();
%>

<%-- 페이지 제목 --%>
<h2><%=title %></h2>

<%-- 검색창 --%>
<form action="<%=root%>/item/list.jsp" method="get">
<select name="column">
		<%if(itemPagination.columnIs("item_type")) {%>
		<option value="item_type" selected>카테고리</option>
		<%}else{ %>
		<option value="item_type">카테고리</option>
		<%} %>
		<%if(itemPagination.columnIs("item_name")) {%>
		<option value="item_name" selected>관광지명</option>
		<%}else{ %>
		<option value="item_name">관광지명</option>
		<%} %>
		<%if(itemPagination.columnIs("item_detail")) {%>
		<option value="item_detail" selected>내용</option>
		<%}else{ %>
		<option value="item_detail">내용</option>
		<%} %>
	</select>
	<input type="search" name="keyword" placeholder="검색어 입력" required value="<%=itemPagination.getKeywordString()%>">
	<input type="submit" value="검색">
</form>

<br>
<%-- 전체 목록 조회 --%>
<%if(!list.isEmpty()){%>
<table border="1" width="500">
	<thead>
		<tr>
			<th>카테고리</th>
			<th>사진</th>
			<th>관광지명</th>
			<th>관광지 소개</th>
			<th>조회수</th>
		</tr>
	</thead>
	<tbody>
		<%for(ItemDto itemDtoList : list){ %>
		
<!-- 		목록을 보여주면서 itemDto의 itemIdx정보를 받는다. -->
		<%
		ItemFileDto itemFileDto = itemFileDao.find2(itemDtoList.getItemIdx());
		%>
		<tr>
			<td align ="center"><%=itemDtoList.getItemType() %></td>
			<td>
			<%-- 첨부파일이 있다면 --%>
			<%if(itemFileDto == null){ %>
					 <img src="http://via.placeholder.com/100x100" class="image">
			<%}else{ %>
					<img src="file/download.nogari?itemFileIdx=<%=itemFileDto.getItemFileIdx()%>" width="20%">
			<%} %>
			</td>
			<td align ="center">
			<a href="detail.jsp?itemIdx=<%=itemDtoList.getItemIdx()%>">
			<%=itemDtoList.getItemName()%>
			</a>
			<%-- 댓글수 --%>
			<%if(itemDtoList.isCountReply()){ %>
				[<%=itemDtoList.getItemCountReply() %>]
			<%} %>
			</td>
			<td><%=itemDtoList.getItemDetail().substring(0, 1) %>....</td>
			<td><%=itemDtoList.getItemCountView() %></td>
		</tr>
		<%} %>
	</tbody>	
</table>
<%}else{ %>
<h2>결과가 없습니다.</h2>
<%} %>

<br><br>

<div>
<%-- [이전] a 태그 --%>
<%if(itemPagination.isBackPage()){ %>
	<%if(itemPagination.isSearch()){%>
		<a href="list.jsp?column=<%=itemPagination.getColumn() %>&keyword<%=itemPagination.getKeyword() %>&p=<%=itemPagination.getBackPage()%>">[이전]</a>
	<%}else{ %>
		<a href="list.jsp?p=<%=itemPagination.getBackPage() %>">[이전]</a>
	<%} %>	
<%}else{%>
	<a>[이전]</a>
<%} %>

<%-- 숫자 a 태그 --%>
<%for(int i = itemPagination.getStartBlock(); i<=itemPagination.getEndBlock(); i++) {%>
	<%if(itemPagination.isSearch()){ %>
		<a href="list.jsp?column=<%=itemPagination.getColumn() %>&keyword<%=itemPagination.getKeyword() %>&p=<%=i %>"><%=i %></a>
	<%}else{ %>
		<a href="list.jsp?p=<%=i %>"><%=i %></a>
	<%} %>
<%} %>

<%-- [다음] a 태그 --%>
<%if(itemPagination.isNextPage()){ %>
	<%if(itemPagination.isSearch()){%>
		<a href="list.jsp?column=<%=itemPagination.getColumn() %>&keyword<%=itemPagination.getKeyword() %>&p=<%=itemPagination.getEndBlock()%>">[다음]</a>
	<%}else{ %>
		<a href="list.jsp?p=<%=itemPagination.getEndBlock() %>">[다음]</a>
	<%} %>	
<%}else{ %>
	<a>[다음]</a>
<%} %>
</div>

<br><br>

<%-- 관리자만 글쓰기 버튼 보이기 --%>
<%if(admin){ %>
<form action="insert.jsp">
	<input type="submit" value="글쓰기">
</form>
<%} %>

 
<!-- 페이지 내용 끝. -->
</SECTION>
<jsp:include page="/resource/template/footer.jsp"></jsp:include>
<SCRIPT TYPE="TEXT/JAVASCRIPT" SRC="<%=root%>/resource/js/footer.js"></SCRIPT>
</BODY>
</HTML>