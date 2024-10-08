local M = {}

-- mapper.xml 파일에서 id 속성 값 찾는 함수
M.open_mapper_xml = function()
  -- 커서 위치의 단어를 가져옴
  local selected_text = vim.fn.expand("<cword>")

  -- 현재 작업 디렉토리를 가져와서 경로 구성
  local xml_paths = vim.fn.glob('src/main/resources/**/*.xml', true, true) -- 모든 XML 파일 찾기
  local found_file = nil
  local found_line = nil

  -- 모든 XML 파일 검색
  for _, xml_path in ipairs(xml_paths) do
    local file = io.open(xml_path, "r") -- XML 파일 열기
    if file then
      local content = file:read("*a")   -- 파일 내용 전체 읽기
      file:close()                      -- 파일 닫기
      -- XML에서 id 속성 값 찾기
      for tag in content:gmatch("<(.-)>") do
        -- tag: <select id="..." ...>
        local id_value = tag:match('id="(.-)"') -- id 속성 값 추출
        if id_value == selected_text then
          found_file = xml_path
          -- id_value의 시작 위치 찾기
          local start_index = content:find('id="' .. id_value .. '"')
          if start_index then
            local count = 0
            local subStr = content:sub(1, start_index)

            -- 줄바꿈갯수 count
            for i = 1, #subStr do
              if subStr:sub(i, i) == '\n' then
                count = count + 1
              end
            end

            found_line = count + 1 -- 해당 줄 번호 계산
          end
          break
        end
      end

      if found_file then
        break
      end
    else
      print("파일을 열 수 없습니다: " .. xml_path) -- 파일 열기 실패 메시지
    end
  end

  -- 파일이 있으면 새 탭에서 열기 및 포커스
  if found_file and found_line then
    vim.cmd('tabedit ' .. found_file) -- 'edit' 대신 'tabedit' 사용
    vim.fn.cursor(found_line, 17) -- 해당 줄로 커서 이동
  else
    print("관련된 Mapper.xml 파일을 찾을 수 없습니다.") -- 파일 찾기 실패 메시지
  end
end

return M
