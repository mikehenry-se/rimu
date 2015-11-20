require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')
require 'rimu'

describe Rimu::Servers do
    before :each do
        @api_key = 'foo'
        @rimu = Rimu::Servers.new(:api_key => @api_key)
    end

    it 'should be a Rimu instance' do
        @rimu.class.should < Rimu
    end

    %w(create status info cancel move resize reinstall reboot shutdown start power_cycle data_transfer).each do |action|
        it "should allow accessing the Rimu::Servers API #{action} method" do
            @rimu.should respond_to(action.to_sym)
        end
    end
    describe "when accessing the Rimu::Servers API create method" do
        it 'should require a params hash' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:create, 1) }.should raise_error(ArgumentError)
        end
        it 'should require arguments' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:create) }.should raise_error(ArgumentError)
        end
        it "should require either instantiation_options or instantiation_via_clone_options set" do
            lambda { @rimu.send(:create, {:dc_location => "DALLAS"}) }.should raise_error(ArgumentError)
        end
        it "should request the correct path" do
            @rimu.expects(:send_request).with {|path, field, method, data| path == "/r/orders/new-vps" }
            @rimu.send(:create, {:instantiation_options=>{:domain_name=>"example.com"}})
        end
        it "should request the correct field" do
            @rimu.expects(:send_request).with {|path, field, method, data| field == "about_order" }
            @rimu.send(:create, {:instantiation_options=>{:domain_name=>"example.com"}})
        end
        it "should have the method parameter set" do
            @rimu.expects(:send_request).with {|path, field, method, data| method == "POST" }
            @rimu.send(:create, {:instantiation_options=>{:domain_name=>"example.com"}})
        end
        it "should have the data parameter set" do
            @rimu.expects(:send_request).with {|path, field, method, data| data == {:new_order_request => {:instantiation_options => {:domain_name => 'example.com'}}} }
            @rimu.send(:create, {:instantiation_options=>{:domain_name=>"example.com"}})
        end
        it "should have either instantiation_options or instantiation_via_clone_options set" do
            @rimu.expects(:send_request).with {|path, field, method, data| data == {:new_order_request => {:instantiation_via_clone_options => {:domain_name => 'example.com'}}} }
            @rimu.send(:create, {:instantiation_via_clone_options=>{:domain_name=>"example.com"}})
        end
    end
    describe "when accessing the Rimu::Servers API reinstall method" do
        it 'should require arguments' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:reinstall) }.should raise_error(ArgumentError)
        end
        it 'should require an integer as the first argument' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:reinstall, {}) }.should raise_error(ArgumentError)
        end
        it 'should require a hash as the second argument' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:reinstall, 10, 10) }.should raise_error(ArgumentError)
        end
        it 'should take an empty hash as the second argument' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:reinstall, 10, {}) }.should_not raise_error
        end
        it "should request the correct path" do
            @rimu.expects(:send_request).with {|path, field, method, data| path == "/r/orders/order-10-dn/vps/reinstall" }
            @rimu.send(:reinstall, 10, {})
        end
        it "should request the correct field" do
            @rimu.expects(:send_request).with {|path, field, method, data| field == "running_vps_info" }
            @rimu.send(:reinstall, 10, {})
        end
        it "should have the method parameter set" do
            @rimu.expects(:send_request).with {|path, field, method, data| method == "PUT" }
            @rimu.send(:reinstall, 10, {})
        end
        it "should have the data parameter set" do
            @rimu.expects(:send_request).with {|path, field, method, data| data == {:reinstall_request => {}} }
            @rimu.send(:reinstall, 10, {})
        end
    end
    # status info cancel reboot shutdown start power_cycle data_transfer)
    %w(status info cancel reboot shutdown start power_cycle data_transfer).each do |action|
        describe "when accessing the Rimu::Servers API #{action} method" do
            it 'should require arguments' do
                @rimu.stubs(:send_request)
                lambda { @rimu.send(action.to_sym) }.should raise_error(ArgumentError)
            end
            it 'should require an integer argument' do
                @rimu.stubs(:send_request)
                lambda { @rimu.send(action.to_sym, {}) }.should raise_error(ArgumentError)
            end
        end
    end
    %w(status info data_transfer).each do |action|
        describe "when accessing the Rimu::Servers API #{action} method" do
            it "should not have the method parameter set" do
                @rimu.expects(:send_request).with {|path, field, method, data| method.nil? && true }
                @rimu.send(action.to_sym, 10)
            end
            it "should not have the data parameter set" do
                @rimu.expects(:send_request).with {|path, field, method, data| data.nil? && true }
                @rimu.send(action.to_sym, 10)
            end
        end
    end
    group_params = {
        :reboot => "RESTARTING",
        :shutdown => "NOTRUNNING",
        :start => "RUNNING",
        :power_cycle => "POWERCYCLING",
    }
    %w(reboot shutdown start power_cycle).each do |action|
        describe "when accessing the Rimu::Servers API #{action} method" do
            it "should request the correct path" do
                @rimu.expects(:send_request).with {|path, field, method, data| path == "/r/orders/order-10-dn/vps/running-state" }
                @rimu.send(action.to_sym, 10)
            end
            it "should request the correct field" do
                @rimu.expects(:send_request).with {|path, field, method, data| field == "running_vps_info" }
                @rimu.send(action.to_sym, 10)
            end
            it "should have the method parameter set" do
                @rimu.expects(:send_request).with {|path, field, method, data| method == "PUT" }
                @rimu.send(action.to_sym, 10)
            end
            it "should have the data parameter set" do
                @rimu.expects(:send_request).with {|path, field, method, data| data == {:running_state_change_request => {:running_state=>group_params[action.to_sym]}} }
                @rimu.send(action.to_sym, 10)
            end
        end
    end
    describe "when accessing the Rimu::Servers API change_state method" do
        it 'should require arguments' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:change_state) }.should raise_error(ArgumentError)
        end
        it 'should require an integer argument' do
            @rimu.stubs(:send_request)
            lambda { @rimu.send(:change_state, {}) }.should raise_error(ArgumentError)
        end
        it "should request the correct path" do
            @rimu.expects(:send_request).with {|path, field, method, data| path == "/r/orders/order-10-dn/vps/running-state" }
            @rimu.send(:change_state, 10, "RESTARTING")
        end
        it "should request the correct field" do
            @rimu.expects(:send_request).with {|path, field, method, data| field == "running_vps_info" }
            @rimu.send(:change_state, 10, "RESTARTING")
        end
        it "should have the method parameter set" do
            @rimu.expects(:send_request).with {|path, field, method, data| method == "PUT" }
            @rimu.send(:change_state, 10, "RESTARTING")
        end
        it "should have the data parameter set" do
            @rimu.expects(:send_request).with {|path, field, method, data| data == {:running_state_change_request => {:running_state=>"RESTARTING"}} }
            @rimu.send(:change_state, 10, "RESTARTING")
        end
    end
end
