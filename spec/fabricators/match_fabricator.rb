Fabricator(:match) do
  # match_members { 2.times.map { Fabricate(:match_member) } }
  match_members { [ Fabricate(:match_member),  Fabricate(:match_member, winner: true) ] }
  league{Fabricate(:league, name:"Test League")}
end

Fabricator(:league) do
  commissioner {Fabricate(:user)}
end
