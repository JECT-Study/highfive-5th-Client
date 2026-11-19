import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it } from 'vitest';
import { TextField } from './TextField';

afterEach(cleanup);

describe('TextField', () => {
  it('invalid면 aria-invalid를 달고, 아니면 달지 않는다', () => {
    const { rerender } = render(<TextField aria-label="이름" invalid />);
    const input = screen.getByRole('textbox', { name: '이름' });
    expect(input.getAttribute('aria-invalid')).toBe('true');

    rerender(<TextField aria-label="이름" />);
    expect(input.hasAttribute('aria-invalid')).toBe(false);
  });
});
