class MockController < Struct.new(:request)

  def vocab_path
    "/vocab"
  end

  def user_path(user)
    "/users/#{user}"
  end

  def test_path(test)
    "/tests/#{test.to_param}"
  end

  def widget_path(widget)
    "/widgets/#{widget.id}"
  end

  def context_path(params)
    "/contexts/#{params[:type]}"
  end
end


