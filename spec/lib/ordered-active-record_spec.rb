require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Post < ActiveRecord::Base
  acts_as_ordered :position
end

describe 'A class Post' do
  it 'should be a subclass of ActiveRecord::Base' do
    Post.new.should be_an(ActiveRecord::Base)
  end

  it 'should have a class method acts_as_ordered' do
    Post.should respond_to(:acts_as_ordered)
  end

  describe 'with acts_as_ordered active on column "position"' do
    before do
      @post1 = Post.create(:text => '1st post', :position => 1)
      @post2 = Post.create(:text => '2nd post', :position => 2)
      @post3 = Post.create(:text => '3rd post', :position => 3)
    end

    it 'should insert a record with position 2' do
      post = Post.create(:text => '4th post', :position => 2)
      @post1.reload.position.should == 1
      @post2.reload.position.should == 3
      @post3.reload.position.should == 4
    end

    it 'should delete a record at position 2' do
      @post2.destroy
      @post1.reload.position.should == 1
      @post3.reload.position.should == 2
    end

    it 'should move the record down from position 1 to position 2' do
      @post1.update_attributes(:position => 2)
      @post1.reload.position.should == 2
      @post2.reload.position.should == 1
      @post3.reload.position.should == 3
    end

    it 'should move up and down from position 1 to position 2 and back'do
      @post1.update_attributes(:position => 2)
      @post1.update_attributes(:position => 1)
      @post1.reload.position.should == 1
      @post2.reload.position.should == 2
      @post3.reload.position.should == 3
    end

    it 'should move the record up from position 3 to position 1' do
      @post3.update_attributes(:position => 1)
      @post1.reload.position.should == 2
      @post2.reload.position.should == 3
      @post3.reload.position.should == 1
    end

    it 'should insert a record with position 5' do
      post = Post.create(:text => '4th post', :position => 5)
      post.position.should == 5
      @post1.reload.position.should == 1
      @post2.reload.position.should == 2
      @post3.reload.position.should == 3
    end

    it 'should do nothing when a record without position is created' do
      post = Post.create(:text => '4th post')
      post.position.should == nil
      @post1.reload.position.should == 1
      @post2.reload.position.should == 2
      @post3.reload.position.should == 3
    end

    it 'should reorder when one record has its position cleared' do
      @post1.update_attributes(:position => nil)
      @post2.reload.position.should == 1
      @post3.reload.position.should == 2
    end

    it 'should reorder when one record has its position filled' do
      post = Post.create(:text => '4th post')
      post.position.should == nil
      @post1.reload.position.should == 1
      @post2.reload.position.should == 2
      @post3.reload.position.should == 3
      post.update_attributes(:position => 2)
      post.position.should == 2
      @post1.reload.position.should == 1
      @post2.reload.position.should == 3
      @post3.reload.position.should == 4
    end
  end
end