require "sinatra"
require "sinatra/content_for"
require "rethinkdb"
require "json"
require "sinatra/reloader" if development?

TABLE = "person_test"
DB    = "sinatra_test"

before %r{.+\.json$} do
  set_database
  content_type "application/json"
end

before do
  set_database
end

after do
  begin
    @db.close if @db
  end
end

get "/" do
  erb :list
end

post "/init" do
  puts "initializing"
  @r.db_create(DB).run(@db)
  @r.table_create(TABLE).run(@db)
  @r.table(TABLE).insert({id: "jimbobtest"}, {upsert: true}).run(@db)
  puts "initilized"
end

# this is the method that works fine from the browser
# but, when rake is ran I get the error
# NoMethodError: undefined method `update'
#    for #<Rack::MockResponse:0x00000002079750>
post "/update/exportable.json" do
  result = update_profile_data(params[:id], "isExportable", params[:export])
  puts result
  result.to_json
end

# this the first line of this method is where the problem is
# I originally have this in a datalayer gem, the same problem exists
# with having it here as well
# NoMethodError: undefined method `update' for
#   <Rack::MockResponse:0x00000002079750>
def update_profile_data(id, field, value)
  @r.table(TABLE).get(id).update(
    {:company_data => {field => value }}
  ).run(@db)
end

def set_database
  begin
    @r  = RethinkDB::RQL.new
    @db = RethinkDB::Connection.new(db: DB)
  rescue Exception => error
    puts error
    logger.error "DB problems...#{error.message}"
    halt(501, "Db problems yo...#{error.message}")
  end
end


