import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';
import { TextArea } from './TextArea';

afterEach(cleanup);

describe('TextArea', () => {
  it('입력하면 글자 수가 바뀐다', () => {
    render(<TextArea aria-label="소개" maxLength={200} />);

    fireEvent.change(screen.getByRole('textbox', { name: '소개' }), {
      target: { value: '하이파이브' },
    });

    expect(screen.getByText('5/200')).toBeDefined();
  });
});
