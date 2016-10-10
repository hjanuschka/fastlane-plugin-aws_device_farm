describe Fastlane::Actions::AwsDeviceFarmAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The aws_device_farm plugin is working!")

      Fastlane::Actions::AwsDeviceFarmAction.run(nil)
    end
  end
end
