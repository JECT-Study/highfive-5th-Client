import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';
import { TextField } from './TextField';

afterEach(cleanup);

describe('TextField', () => {
  it('보조행을 입력칸 설명으로 연결하고 입력 변경도 전달한다', () => {
    let changed = '';
    render(
      <TextField
        aria-label="공연장"
        subtext="서울 마포구"
        onChange={(event) => {
          changed = event.currentTarget.value;
        }}
      />,
    );
    const input = screen.getByRole('textbox', { name: '공연장' });

    fireEvent.change(input, { target: { value: '공연장 주소' } });

    expect(changed).toBe('공연장 주소');
    expect(input.getAttribute('aria-describedby')).toBe(screen.getByText('서울 마포구').id);
  });

  it('invalid면 aria-invalid를 달고, 아니면 달지 않는다', () => {
    const { rerender } = render(<TextField aria-label="이름" invalid />);
    const input = screen.getByRole('textbox', { name: '이름' });
    expect(input.getAttribute('aria-invalid')).toBe('true');

    rerender(<TextField aria-label="이름" />);
    expect(input.hasAttribute('aria-invalid')).toBe(false);
  });
});
