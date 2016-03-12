class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    app.call(env)
  rescue Exception => e
      res = Rack::Response.new
      file = create_file(e)
      res.write(file)
      res['Content Type'] = 'text/html'
      res.finish
  end

  private

  def create_file(exc)

    source_code_error_info = exc.backtrace[0].split(":")

    path = source_code_error_info.first
    line = source_code_error_info[1].to_i

    source_file = File.readlines(path)

    start = (line - 5 < 0) ? 0 : (line - 5)
    final = (line + 5 >= source_file.length) ? (source_file.length-1) : (line + 5)

    selected_lines = source_file[start..final]

    val = <<-HTML
      <h1> Stack Trace: </h1>

      <% exc.backtrace.each do |line|%>
        <p> <%= line %> </p>
      <% end %>

      <h1> Error Message: </h1>
      <h3> #{exc.message} </h3>

      <h2> Source Code: </h2>
      <ol start=<%=line-5%>>
      <% selected_lines.each do |line| %>
        <li><%= line %></li>
      <% end %>
      </ol>
    HTML

    erb_template = ERB.new(val)
    erb_result = erb_template.result(binding)
  end
end