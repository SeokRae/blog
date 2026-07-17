// 테마 원본(assets/js/search.js)은 lunr로 인덱싱하는데, lunr 기본 파이프라인의
// trimmer가 \W(= [^A-Za-z0-9_])로 토큰을 잘라 한글 토큰을 빈 문자열로 만든다.
// 한국어 질의가 전부 0건이 되므로 substring 매칭으로 대체한다. (#12)

{
  const SEARCH_BOX_ID = "search-box";
  const NO_RESULTS_MESSAGE_ID = "not-found";
  const SEARCH_RESULTS_CONTAINER_ID = "search-results";
  const QUERY_VARIABLE_URL_STRING = "query";
  const SEARCHED_FIELDS = ["title", "tags", "category", "author", "content"];
  const SNIPPET_LENGTH = 150;

  // 순수 함수 — 브라우저 없이 검증할 수 있도록 DOM에 의존하지 않는다.
  const searchStore = (store, query) => {
    const needle = String(query == null ? "" : query).trim().toLowerCase();
    if (needle === "") return [];

    const matches = [];
    for (const ref of Object.keys(store)) {
      const postJson = store[ref];
      const haystack = SEARCHED_FIELDS
        .map(field => postJson[field] || "")
        .join(" ")
        .toLowerCase();
      if (!haystack.includes(needle)) continue;

      matches.push({
        ref: ref,
        titleHit: String(postJson.title || "").toLowerCase().includes(needle)
      });
    }

    // 제목이 걸린 글을 먼저. sort는 안정적이므로 그 안에서는 site.posts 순서(최신순)가 유지된다.
    return matches
      .sort((a, b) => Number(b.titleHit) - Number(a.titleHit))
      .map(match => ({ ref: match.ref }));
  };

  const extractUrlQueryParameter = (fallback = '') => {
    const urlSearchParams = new URLSearchParams(window.location.search);
    const queryParameter = urlSearchParams.get(QUERY_VARIABLE_URL_STRING);
    return queryParameter === null ? fallback : queryParameter;
  }

  const setSearchBoxValue = (searchBoxValue) => {
    document
      .getElementById(SEARCH_BOX_ID)
      .setAttribute("value", searchBoxValue);
  }

  const showNoResultsMessage = () => {
    document
      .getElementById(NO_RESULTS_MESSAGE_ID)
      .style
      .display = "block";
  }

  const setSearchResultsHtml = (innerHtml) => {
    document
      .getElementById(SEARCH_RESULTS_CONTAINER_ID)
      .innerHTML = innerHtml;
  }

  const createPostListingHtml = (postItem) => `
    <h2>
      <a class='search-link' href='${postItem.url}'>${postItem.title}</a>
    </h2>

    <div class='meta'>
      ${postItem.date}
    </div>

    <p>
      ${postItem.content.substring(0, SNIPPET_LENGTH)}...
    </p>
  `;

  const displaySearchResults = (results) => {
    setSearchResultsHtml(
      results
        .map(result => createPostListingHtml(window.store[result.ref]))
        .join('')
    );
  }

  const searchFromUrl = () => {
    const searchTerm = extractUrlQueryParameter();
    setSearchBoxValue(searchTerm);
    const results = searchStore(window.store, searchTerm);
    results.length === 0 ? showNoResultsMessage() : displaySearchResults(results);
  }

  if (typeof module !== "undefined" && module.exports) {
    module.exports = { searchStore };
  } else {
    searchFromUrl();
  }
};
