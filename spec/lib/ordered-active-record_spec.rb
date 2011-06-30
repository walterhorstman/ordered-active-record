require 'spec_helper'

describe 'A model Post' do
  context 'with acts_as_ordered enabled on column "position"' do
    before do
      @post1 = Post.create(:text => '1st post', :position => 1)
      @post2 = Post.create(:text => '2nd post', :position => 2)
      @post3 = Post.create(:text => '3rd post', :position => 3)
    end

    it 'should insert a record with position 2' do
      post = Post.create(:text => '4th post', :position => 2)
      post.position.should == 2
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
      @post1.update_attributes({'position' => 2})
      @post1.reload.position.should == 2
      @post2.reload.position.should == 1
      @post3.reload.position.should == 3
    end

    it 'should move up and down from position 1 to position 2 and back' do
      @post1.update_attributes({'position' => 2})
      @post1.reload.update_attributes({'position' => 1})
      @post1.reload.position.should == 1
      @post2.reload.position.should == 2
      @post3.reload.position.should == 3
    end

    it 'should move the record up from position 3 to position 1' do
      @post3.update_attributes({'position' => 1})
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

    it 'should prevent adding ordered columns twice or more' do
      Post.send(:acts_as_ordered, :position)
      post = Post.create(:text => '4th post', :position => 2)
      post.position.should == 2
      @post1.reload.position.should == 1
      @post2.reload.position.should == 3
      @post3.reload.position.should == 4
    end
  end
end