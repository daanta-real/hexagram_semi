package servlet.event;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import beans.EventDao;
import beans.EventDto;
import beans.EventFileDao;
import beans.EventFileDto;
import system.Settings;
import util.users.Sessioner;

@SuppressWarnings("serial")
@WebServlet (urlPatterns = "/event/insert.nogari")
public class EventInsertServlet extends HttpServlet{

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {

			// 파일 리퀘 준비
			String savePath = Settings.PATH_FILES;
			int maxSize = 5 * 1024 * 1024;
			String encoding = "UTF-8";
			DefaultFileRenamePolicy policy = new DefaultFileRenamePolicy();
			MultipartRequest mRequest = new MultipartRequest(req, savePath, maxSize, encoding, policy);

			// 값 검사
			String evN = mRequest.getParameter("eventName");
			String evD = mRequest.getParameter("eventDetail");
			if(evN == null || evN.equals("") || evD == null || evD.equals("")) {
				System.out.println("[이벤트 - 신규] 글 제목 혹은 글 내용이 입수되지 않았습니다.");
				throw new Exception();
			}

			// DAO/DTO 생성 후 각종 값 넣기
			EventDao eventDao = new EventDao();
			EventDto eventDto = new EventDto();
			int nextSeq = eventDao.getNextSequence();
			eventDto.setEventIdx(nextSeq);
			eventDto.setUsersIdx(Sessioner.getUsersIdx(req));
			eventDto.setEventName(evN);
			eventDto.setEventDetail(evD);

			// 글 삽입
			eventDao.insert(eventDto);

			// 파일이 있을 경우, 파일도 삽입
			if(mRequest.getFile("attach") != null) {

				EventFileDto eventFileDto = new EventFileDto();
				eventFileDto.setEventNo(nextSeq);
				eventFileDto.setEventFileUploadName(mRequest.getOriginalFileName("attach")); // 업로드한 사람한테 보이는 가짜 이름
				eventFileDto.setEventFileSaveName(mRequest.getFilesystemName("attach")); // 서버에 저장되는 실제 이름
				eventFileDto.setEventFileType(mRequest.getContentType("attach"));
				eventFileDto.setEventFileSize(mRequest.getFile("attach").length());

				EventFileDao eventFileDao = new EventFileDao();
				eventFileDao.insert(eventFileDto);

			}

			resp.sendRedirect("detail.jsp?eventIdx=" + nextSeq);

		}

		catch(Exception e){

			System.out.println("[이벤트 - 신규] 새 데이터 등록 중 에러가 발생했습니다.");
			e.printStackTrace();
			resp.sendError(500);

		}

	}
}
