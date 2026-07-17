// 검색 매칭 계약. 한국어 질의가 조용히 0건이 되는 회귀를 막는다. (#12)
//
// 실행: node test/search_test.js

const assert = require("assert");
const { searchStore } = require("../assets/js/search.js");

// search.html의 window.store와 같은 모양 — liquid가 채우는 필드를 그대로 흉내낸다.
const store = {
  "flowcast": {
    title: "서비스는 움직이는데, 문서는 멈춰 있었다",
    tags: "문서화, 아키텍처, 시각화, AI, flowcast, 회고",
    category: "",
    author: "",
    content: "다이어그램을 다시 그리는 비용은 두 번째 수정에서 드러난다.",
    date: "July 15, 2026",
    url: "/blog/flowcast/"
  },
  "type-theme": {
    title: "옮긴 이유가 틀렸다는 걸 뒤늦게 알았다",
    tags: "Jekyll, GitHub Pages, 블로그, 회고",
    category: "",
    author: "",
    content: "Chirpy에서 Type Theme로 갈아탔다. nojekyll 파일이 빌드를 막고 있었다.",
    date: "July 13, 2026",
    url: "/blog/type-theme/"
  }
};

const refs = (query) => searchStore(store, query).map(result => result.ref);

// 한국어 — 이 블로그의 주 언어. lunr trimmer 회귀 시 전부 0건이 된다.
assert.deepStrictEqual(refs("문서"), ["flowcast"], "제목의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("다이어그램"), ["flowcast"], "본문의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("블로그"), ["type-theme"], "태그의 한글이 검색돼야 한다");
assert.deepStrictEqual(refs("회고"), ["flowcast", "type-theme"], "여러 글의 공통 태그가 모두 걸려야 한다");

// 영문 — 기존 동작 유지
assert.deepStrictEqual(refs("Chirpy"), ["type-theme"], "영문이 검색돼야 한다");
assert.deepStrictEqual(refs("chirpy"), ["type-theme"], "대소문자를 구분하지 않아야 한다");

// 순위 — 제목이 걸린 글이 먼저
assert.deepStrictEqual(refs("Jekyll"), ["type-theme"], "태그만 걸려도 검색돼야 한다");
assert.deepStrictEqual(
  searchStore({ a: { title: "x", content: "쿼리" }, b: { title: "쿼리", content: "x" } }, "쿼리")
    .map(result => result.ref),
  ["b", "a"],
  "제목이 걸린 글이 본문만 걸린 글보다 앞서야 한다"
);

// 빈 질의 — 전체 매칭으로 새지 않아야 한다
assert.deepStrictEqual(refs(""), [], "빈 질의는 0건");
assert.deepStrictEqual(refs("   "), [], "공백뿐인 질의는 0건");
assert.deepStrictEqual(refs(null), [], "null 질의는 0건");

// 없는 말
assert.deepStrictEqual(refs("존재하지않는단어"), [], "매칭 없으면 0건");

console.log("search_test.js: 12 assertions, 통과");
