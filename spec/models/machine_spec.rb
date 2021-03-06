require 'spec_helper'

describe Machine do
  before :each do
    @owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)
  end

  let(:attributes) do
    {
      fqdn: 'machine.example.com',
      owner: @owner
    }
  end

  let(:machine) { described_class.new(attributes) }

  describe 'soft-delete via paranoia' do
    it 'is restorable after delete' do
      m = FactoryBot.create(:machine, owner: @owner)
      expect(m).to respond_to(:paranoia_destroyed?)
      m.delete

      expect(m.paranoia_destroyed?).to be true
      expect(m.deleted?).to be true

      m.restore
      expect(m.paranoia_destroyed?).to be false
      expect(m.deleted?).to be false
    end
  end

  describe 'validations' do
    it 'is invalid without a fqdn' do
      attributes.delete(:fqdn)

      expect(machine).to be_invalid
    end

    it 'is invalid with a duplicate fqdn' do
      described_class.create!(attributes)

      expect(machine).to be_invalid
    end

    it 'is invalid with a duplicate fqdn of a deleted machine' do
      m = FactoryBot.create(:machine, fqdn: "deleted.example.com")
      m.delete
      x = FactoryBot.build(:machine, fqdn: "deleted.example.com")
      expect(x).to be_invalid
    end

    describe 'fqdn format' do
      context 'fqdn = example.com' do
        before { machine.fqdn = 'example.com' }

        it 'is valid' do
          expect(machine).to be_valid
        end
      end

      context 'fqdn = server1.example.com' do
        before { machine.fqdn = 'server1.example.com' }

        it 'is valid' do
          expect(machine).to be_valid
        end
      end

      context 'fqdn = server1.fra.de.foo.example.com' do
        before { machine.fqdn = 'server1.fra.de.foo.example.com' }

        it 'is valid' do
          expect(machine).to be_valid
        end
      end

      context 'fqdn = foo' do
        before { machine.fqdn = 'foo' }

        it 'is invalid' do
          expect(machine).to be_invalid
        end
      end

      context 'fqdn = foo bar' do
        before { machine.fqdn = 'foo bar' }

        it 'is invalid' do
          expect(machine).to be_invalid
        end
      end

      context 'fqdn = -server.example.com' do
        before { machine.fqdn = '-server.example.com' }

        it 'is invalid' do
          expect(machine).to be_invalid
        end
      end

      context 'fqdn = server-.example.com' do
        before { machine.fqdn = 'server-.example.com' }

        it 'is invalid' do
          expect(machine).to be_invalid
        end
      end

      context 'fqdn = server_1.example.com' do
        # underscores are allowed now though not RFC-compliant
        before { machine.fqdn = 'server_1.example.com' }

        it 'is valid' do
          expect(machine).to be_valid
        end
      end

      context 'fqdn = server1.example.com\'' do
        before { machine.fqdn = "server1.example.com'" }

        it 'is invalid' do
          expect(machine).to be_invalid
        end
      end

      context 'fqdn is an IP address' do
        it 'is valid' do
          machine.fqdn = "192.168.0.1"
          expect(machine).to be_valid
        end

        it 'is valid' do
          machine.fqdn = "3.3.3.3"
          expect(machine).to be_valid
        end

        it 'is valid' do
          machine.fqdn = "10.48.0.200"
          expect(machine).to be_valid
        end

        it 'is invalid' do
          machine.fqdn = "410.48.0.200"
          expect(machine).to be_invalid
        end
      end
    end
  end

  describe '#backup_type' do
    it 'defaults to 0' do
      expect(machine.backup_type).to eq(0)
    end
  end

  describe '#auto_update' do
    it 'defaults to false' do
      expect(machine.auto_update).to eq(false)
    end
  end

  describe '#manual?' do
    context 'when auto_update is true' do
      before { machine.auto_update = true }

      it 'returns false' do
        expect(machine.manual?).to eq(false)
      end
    end

    context 'when auto_update is false' do
      before { machine.auto_update = false }

      it 'returns false' do
        expect(machine.manual?).to eq(true)
      end
    end

    context 'when auto_update is changed to false' do
      before { machine.auto_update = true }

      it 'returns true' do
        machine.auto_update = false
        expect(machine.manual?).to eq(true)
      end
    end
  end

  describe '#outdated?' do
    context 'when machine is outdated' do
      before do
        machine.updated_at = 2.days.ago
      end

      it 'returns true' do
        expect(machine).to be_outdated
      end
    end

    context 'when machine receives frequent updates' do
      before do
        machine.updated_at = 12.hours.ago
      end

      it 'returns false' do
        expect(machine).to_not be_outdated
      end
    end

    context 'when machine has not been updated' do
      before do
        machine.updated_at = nil
      end

      it 'returns true' do
        expect(machine).to be_outdated
      end
    end
  end
end
