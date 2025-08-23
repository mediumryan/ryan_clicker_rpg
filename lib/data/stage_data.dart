class StageData {
  static String getStageName(int stage) {
    if (stage >= 1 && stage <= 50) {
      return '시작의 마을';
    } else if (stage >= 51 && stage <= 100) {
      return '시작의 마을 외곽';
    } else if (stage >= 101 && stage <= 150) {
      return '설산 입구';
    } else if (stage >= 151 && stage <= 200) {
      return '어두운 동굴 초입';
    } else if (stage >= 201 && stage <= 250) {
      return '어두운 동굴 깊은 곳';
    } else if (stage >= 251 && stage <= 300) {
      return '어두운 동굴 깊은 곳II';
    } else if (stage >= 301 && stage <= 350) {
      return '고블린 영지';
    } else if (stage >= 351 && stage <= 400) {
      return '소인족 마을';
    } else if (stage >= 401 && stage <= 450) {
      return '리자드 습지';
    } else if (stage >= 451 && stage <= 500) {
      return '바위산 초입';
    } else if (stage >= 501 && stage <= 550) {
      return '바위산 중턱';
    } else if (stage >= 551 && stage <= 600) {
      return '바위산 정상';
    } else if (stage >= 601 && stage <= 650) {
      return '이상한 마을';
    } else if (stage >= 651 && stage <= 700) {
      return '엘프 숲';
    } else if (stage >= 701 && stage <= 750) {
      return '요정 숲';
    } else if (stage >= 751 && stage <= 800) {
      return '이상한 숲';
    } else if (stage >= 801 && stage <= 850) {
      return '정령의 숲';
    } else if (stage >= 851 && stage <= 900) {
      return '바위산 끝자락';
    } else if (stage >= 901 && stage <= 950) {
      return '신성국으로 가는 길';
    } else if (stage >= 951 && stage <= 1000) {
      return '신성국 입구';
    } else if (stage >= 1001 && stage <= 1050) {
      return '신성국 교회';
    } else if (stage >= 1051 && stage <= 1100) {
      return '신성한 제단';
    } else if (stage >= 1101 && stage <= 1150) {
      return '세뇌된 마을';
    } else if (stage >= 1151 && stage <= 1200) {
      return '마을 공동묘지 입구';
    } else if (stage >= 1201 && stage <= 1250) {
      return '마을 공동묘지';
    } else if (stage >= 1251 && stage <= 1300) {
      return '마을 공동묘지 중심부';
    } else if (stage >= 1301 && stage <= 1350) {
      return '항구로 가는 길';
    } else if (stage >= 1351 && stage <= 1400) {
      return '항구로 가는 길 II';
    } else if (stage >= 1401 && stage <= 1450) {
      return '피투성이 해안';
    } else if (stage >= 1451 && stage <= 1500) {
      return '피폐한 항구도시';
    } else if (stage >= 1501 && stage <= 1550) {
      return '항구도시 외곽';
    } else if (stage >= 1551 && stage <= 1600) {
      return '데빌 로드';
    } else if (stage >= 1601 && stage <= 1650) {
      return '데빌 로드 II';
    } else if (stage >= 1651 && stage <= 1700) {
      return '마계 입구';
    } else if (stage >= 1701 && stage <= 1750) {
      return '마계 중심';
    } else if (stage >= 1751 && stage <= 1800) {
      return '마계 중심부';
    } else if (stage >= 1801 && stage <= 1850) {
      return '드래곤 로드';
    } else if (stage >= 1851 && stage <= 1900) {
      return '드래곤 레어 초입';
    } else if (stage >= 1901 && stage <= 1950) {
      return '드래곤 레어 중심부 II';
    } else if (stage >= 1951 && stage <= 2000) {
      return '드래곤 레어 깊은곳';
    }
    return '미지의 영역'; // Default for stages beyond defined ranges
  }
}