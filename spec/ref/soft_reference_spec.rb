require 'spec_helper'

describe Ref::SoftReference do
  describe '#object' do
    context 'when has not garbage collected objects' do
      it 'gets the object' do
        obj = Object.new
        ref = Ref::SoftReference.new(obj)

        expect(obj).to eq ref.object
        expect(obj.object_id).to eq ref.referenced_object_id
      end
    end

    context 'when has a lot of objects' do
      # Since we can't reliably control the garbage collector, this is a brute force test.
      # It might not always fail if the garbage collector and memory allocator don't
      # cooperate, but it should fail often enough on continuous integration to
      # hilite any problems. Set the environment variable QUICK_TEST to "true" if you
      # want to make the tests run quickly.
      it 'get the correct object' do
        id_to_ref = {}
        (ENV["QUICK_TEST"] == "true" ? 1000 : 100000).times do |i|
          obj = Object.new
          if id_to_ref.key?(obj.object_id)
            ref = id_to_ref[obj.object_id]
            if ref.object
              fail "soft reference found with a live reference to an object that was not the one it was created with"
              break
            end
          end

          %w(Here are a bunch of objects that are allocated and can then be cleaned up by the garbage collector)
          id_to_ref[obj.object_id] = Ref::SoftReference.new(obj)
          if i % 1000 == 0
            GC.start
            sleep(0.01)
          end
        end
      end
    end

    context 'when references are not collected immediately' do
      it "the object can't be nil" do
        ref = Ref::SoftReference.new(Object.new)
        9.times{ arr = %w(allocate some memory on the heap); arr *= 100; GC.start }
        expect(ref.object).to_not be_nil
      end
    end
  end

  describe '#inspect' do
    context 'when GC is called' do
      it 'inspects not be nil' do
        ref = Ref::SoftReference.new(Object.new)
        expect(ref.inspect).to_not be_nil
        GC.start
        GC.start
        expect(ref.inspect).to_not be_nil
      end
    end
  end
end
