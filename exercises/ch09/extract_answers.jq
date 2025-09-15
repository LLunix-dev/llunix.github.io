. as $input |
if ($input.sequences[0].staticConfigs[0]? | .grid?) then
  ($input.sequences[0].staticConfigs[0].grid[1] // "" | scan("<p>[^<]*<gap id=\"([^\"]+)\">[^<]*</gap>\\s*(.+?)</p>"; "g") | map([.[0], .[1] | ltrimstr(" ")])) as $id_to_text |
  .sequences[0].configs // [] | map(
    if .type == "gap" and .id then
      ($id_to_text | map(select(.[0] == .id) | .[1])[0] // "") | select(. != "")
    else
      empty
    end
  ) | map(select(. != null and . != ""))
else
  .sequences[0].configs // [] | map(
    if type != "object" or . == null or .type == null then
      empty
    elif .type == "dropdown" then
      .additionalAnswers // [] | map(select(.correct == true) | .answer) | .[0] // empty
    elif .type == "quiz" or .type == "single-choice" then
      (.correctAnswer // "") | gsub("</?p>"; "") | gsub("<b>[^<]*</b>"; "") | select(. != "")
    elif .type == "gap" then
      (.correctAnswer // "") | gsub("</?p>"; "") | gsub("<b>[^<]*</b>"; "") | select(. != "")
    elif .type == "jumbled-dialogue" then
      .sentences // [] | map(.text // "" | gsub("<[^>]+>"; "") | select(. != ""))
    else
      empty
    end
  ) | flatten | map(select(. != null and . != ""))
end
