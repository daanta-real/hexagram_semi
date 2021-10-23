package servlet.item;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import beans.UsersDao;
import beans.UsersDto;

@WebServlet(urlPatterns = "/jsp/item/login.nogari")
public class ItemTemporaryLoginServlet extends HttpServlet{
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			UsersDao usersDao = new UsersDao();
			UsersDto usersDto = usersDao.login(req.getParameter("usersId"),req.getParameter("usersPw"));
			
			if(usersDto != null) {
				req.getSession().setAttribute("usersKey", usersDto.getUsers_idx());
				req.getSession().setAttribute("usersGrade", usersDto.getUsers_grade());
				resp.sendRedirect(req.getContextPath()+"/jsp/item/main.jsp?");
			}else {
				resp.sendRedirect(req.getContextPath()+"/jsp/item/main_before.jsp?");
			}
				
			
		}catch (Exception e) {
			e.printStackTrace();
			resp.sendError(500);
		}
	}
}