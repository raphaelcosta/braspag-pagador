$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'braspag'
require 'spec'
require 'spec/autorun'
require 'ruby-debug'

MERCHANT_ID = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
BASE_URL = 'https://homologacao.pagador.com.br'

Spec::Runner.configure do |config|

end
